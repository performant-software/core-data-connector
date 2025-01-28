module CoreDataConnector
  module Import
    class Places < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_places
             SET z_place_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH
              
          update_places AS (
          
            UPDATE core_data_connector_places places
               SET z_place_id = z_places.id,
                   user_defined = z_places.user_defined,
                   import_id = z_places.import_id,
                   updated_at = current_timestamp
              FROM #{table_name} z_places
             WHERE z_places.place_id = places.id
              
          ),

          update_place_names AS (

            UPDATE core_data_connector_place_names place_names
               SET name = z_places.name,
                   updated_at = current_timestamp
              FROM #{table_name} z_places
             WHERE z_places.place_id = place_names.place_id
               AND place_names.primary = TRUE

          )

          UPDATE core_data_connector_place_geometries place_geometries
             SET geometry = st_makepoint(z_places.longitude, z_places.latitude),
                 updated_at = current_timestamp
            FROM #{table_name} z_places
           WHERE z_places.place_id = place_geometries.place_id
        SQL

        execute <<-SQL.squish
          WITH 

          insert_places AS (

          INSERT INTO core_data_connector_places (
            project_model_id, 
            uuid, 
            z_place_id, 
            user_defined,
            import_id,
            created_at, 
            updated_at
          )
          SELECT z_places.project_model_id, 
                 z_places.uuid, 
                 z_places.id, 
                 z_places.user_defined,
                 z_places.import_id,
                 current_timestamp, 
                 current_timestamp
            FROM #{table_name} z_places
           WHERE z_places.place_id IS NULL
          RETURNING id AS place_id, z_place_id

          ),

          insert_place_names AS (

          INSERT INTO core_data_connector_place_names (place_id, name, "primary", created_at, updated_at)
          SELECT insert_places.place_id, z_places.name, TRUE, current_timestamp, current_timestamp
            FROM insert_places
            JOIN #{table_name} z_places ON z_places.id = insert_places.z_place_id
          RETURNING id

          ),

          insert_place_geometries AS (

          INSERT INTO core_data_connector_place_geometries (place_id, geometry, created_at, updated_at)
          SELECT insert_places.place_id, st_makepoint(z_places.longitude, z_places.latitude), current_timestamp, current_timestamp
            FROM insert_places
            JOIN #{table_name} z_places ON z_places.id = insert_places.z_place_id
          RETURNING id

          )

          UPDATE #{table_name} z_places
             SET place_id = insert_places.place_id
            FROM insert_places
           WHERE insert_places.z_place_id = z_places.id
        SQL
      end

      def transform
        execute <<-SQL.squish
          UPDATE #{table_name} z_places
             SET place_id = places.id,
                 user_defined = places.user_defined
            FROM core_data_connector_places places
           WHERE places.uuid = z_places.uuid
             AND z_places.uuid IS NOT NULL
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
           name: 'name',
           type: 'VARCHAR',
           copy: true
        }, {
           name: 'latitude',
           type: 'DECIMAL',
           copy: true
         }, {
           name: 'longitude',
           type: 'DECIMAL',
           copy: true
         }, {
           name: 'place_id',
           type: 'INTEGER',
        }, {
           name: 'user_defined',
           type: 'JSONB'
        }, {
           name: 'import_id',
           type: 'UUID'
         }]
      end

      def table_name_prefix
        'z_places'
      end
    end
  end
end