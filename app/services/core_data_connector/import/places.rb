module CoreDataConnector
  module Import
    class Places < Base
      protected

      def column_names
        [{
           name: 'place_id',
           type: 'INTEGER',
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
         }]
      end

      def load
        execute <<-SQL.squish
          WITH 

          insert_places AS (

          INSERT INTO core_data_connector_places (project_model_id, z_place_id, user_defined, created_at, updated_at)
          SELECT z_places.project_model_id, z_places.id, user_defined, current_timestamp, current_timestamp
            FROM #{table_name} z_places
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

        execute <<-SQL.squish
          UPDATE core_data_connector_places
             SET z_place_id = NULL
        SQL
      end

      def table_name_prefix
        'z_places'
      end
    end
  end
end