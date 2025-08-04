module CoreDataConnector
  module Import
    class People < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_people
             SET z_person_id = NULL
        SQL

        execute <<-SQL.squish
          VACUUM ANALYZE core_data_connector_people, core_data_connector_person_names
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH
              
          update_people AS (
          
            UPDATE core_data_connector_people people
               SET z_person_id = z_people.id,
                   biography = z_people.biography,
                   user_defined = z_people.user_defined,
                   import_id = z_people.import_id,
                   updated_at = current_timestamp
              FROM #{table_name} z_people
             WHERE z_people.person_id = people.id
              
          )

          UPDATE core_data_connector_person_names person_names
             SET last_name = z_people.last_name,
                 first_name = z_people.first_name,
                 middle_name = z_people.middle_name,
                 updated_at = current_timestamp
           FROM #{table_name} z_people
          WHERE z_people.person_id = person_names.person_id
            AND person_names.primary = TRUE
        SQL

        execute <<-SQL.squish
          WITH 
          
          insert_people AS (

          INSERT INTO core_data_connector_people (
            project_model_id, 
            uuid, 
            z_person_id, 
            biography, 
            user_defined,
            import_id,
            created_at, 
            updated_at
          )
          SELECT z_people.project_model_id, 
                 z_people.uuid, 
                 z_people.id, 
                 z_people.biography, 
                 z_people.user_defined,
                 z_people.import_id,
                 current_timestamp, 
                 current_timestamp
            FROM #{table_name} z_people
           WHERE z_people.person_id IS NULL
          RETURNING id AS person_id, z_person_id

          ),

          insert_person_names AS (

          INSERT INTO core_data_connector_person_names (person_id, last_name, first_name, middle_name, "primary", created_at, updated_at)
          SELECT insert_people.person_id, z_people.last_name, z_people.first_name, z_people.middle_name, TRUE, current_timestamp, current_timestamp
            FROM insert_people
            JOIN #{table_name} z_people ON z_people.id = insert_people.z_person_id
          RETURNING id

          )

          UPDATE #{table_name} z_people
             SET person_id = insert_people.person_id
            FROM insert_people
           WHERE insert_people.z_person_id = z_people.id
        SQL
      end

      def transform
        execute <<-SQL.squish
          UPDATE #{table_name} z_people
             SET person_id = people.id,
                 user_defined = people.user_defined
            FROM core_data_connector_people people
           WHERE people.uuid = z_people.uuid
             AND z_people.uuid IS NOT NULL
        SQL

        super
      end

      protected

      def column_names
        [{
           name: 'project_model_id',
           type: 'INTEGER',
           copy: true
         }, {
           name: 'uuid',
           type: 'UUID',
           copy: true
         }, {
           name: 'last_name',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'first_name',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'middle_name',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'biography',
           type: 'TEXT',
           copy: true
         }, {
           name: 'person_id',
           type: 'INTEGER'
         }, {
           name: 'user_defined',
           type: 'JSONB'
         }, {
           name: 'import_id',
           type: 'UUID'
         }]
      end

      def table_name_prefix
        'z_people'
      end
    end
  end
end