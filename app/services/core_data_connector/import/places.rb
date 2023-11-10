module CoreDataConnector
  module Import
    class Places < Base
      protected

      def column_names
        [{
           name: 'name',
           type: 'VARCHAR'
        }, {
           name: 'latitude',
           type: 'DECIMAL'
         }, {
           name: 'longitude',
           type: 'DECIMAL'
         }]
      end

      def load
        execute <<-SQL.squish
          WITH 
          
          insert_places AS (

          INSERT INTO core_data_connector_places (project_model_id, user_defined, z_place_id, created_at, updated_at)
          SELECT #{project_model_id}, #{user_defined_expression}, z_places.id, current_timestamp, current_timestamp
            FROM #{table_name} z_places
          RETURNING id AS place_id, z_place_id

          ),

          insert_place_names AS (

          INSERT INTO core_data_connector_place_names (place_id, name, "primary", created_at, updated_at)
          SELECT insert_places.place_id, z_places.name, TRUE, current_timestamp, current_timestamp
            FROM insert_places
            JOIN #{table_name} z_places ON z_places.id = insert_places.z_place_id
          RETURNING id

          )

          INSERT INTO core_data_connector_place_geometries (place_id, geometry, created_at, updated_at)
          SELECT insert_places.place_id, st_makepoint(z_places.longitude, z_places.latitude), current_timestamp, current_timestamp
            FROM insert_places
            JOIN #{table_name} z_places ON z_places.id = insert_places.z_place_id
        SQL
      end

      def table_name_prefix
        'z_places'
      end
    end
  end
end