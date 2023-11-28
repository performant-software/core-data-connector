module CoreDataConnector
  module Import
    class People < Base
      protected

      def column_names
        [{
           name: 'person_id',
           type: 'INTEGER'
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
         }]
      end

      def load
        execute <<-SQL.squish
          WITH 
          
          insert_people AS (

          INSERT INTO core_data_connector_people (project_model_id, z_person_id, biography, user_defined, created_at, updated_at)
          SELECT z_people.project_model_id, z_people.id, biography, user_defined, current_timestamp, current_timestamp
            FROM #{table_name} z_people
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

        execute <<-SQL.squish
          UPDATE core_data_connector_people
             SET z_person_id = NULL
        SQL
      end

      def table_name_prefix
        'z_people'
      end
    end
  end
end