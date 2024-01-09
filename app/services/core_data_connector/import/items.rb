module CoreDataConnector
  module Import
    class Items < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE
          core_data_connector_items
            SET z_item_id = NULL
        SQL

        execute <<-SQL.squish
          UPDATE
          core_data_connector_names
            SET z_source_id = NULL,
                z_source_type = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_items items
             SET z_item_id = z_items.id,
                 user_defined = z_items.user_defined,
                 updated_at = current_timestamp
            FROM #{table_name} z_items
           WHERE z_items.item_id = items.id
        SQL

        execute <<-SQL.squish
        WITH

        insert_items AS (

          INSERT INTO core_data_connector_items (
            project_model_id,
            uuid,
            z_item_id,
            user_defined,
            created_at,
            updated_at
          )
          SELECT z_items.project_model_id, 
                 z_items.uuid, 
                 z_items.id, 
                 z_items.user_defined, 
                 current_timestamp, 
                 current_timestamp
            FROM #{table_name} z_items
            WHERE z_items.item_id IS NULL
          RETURNING id AS item_id, z_item_id

        ),

        insert_names AS (

          INSERT INTO core_data_connector_names
            ("name", z_source_id, z_source_type, created_at, updated_at)
            SELECT z_items.name,
                   insert_items.item_id,
                   'CoreDataConnector::Item',
                   current_timestamp,
                   current_timestamp
              FROM insert_items
              JOIN #{table_name} z_items ON z_items.id = insert_items.z_item_id
          RETURNING id AS name_id, z_source_id, z_source_type, "name"

        )

        INSERT INTO core_data_connector_source_titles
          (nameable_type, nameable_id, name_id, "primary", created_at, updated_at)
          SELECT 'CoreDataConnector::Item',
                 insert_items.item_id,
                 insert_names.name_id,
                 TRUE,
                 current_timestamp,
                 current_timestamp
            FROM insert_items
            JOIN insert_names
              ON insert_names.z_source_id = insert_items.item_id
             AND insert_names.z_source_type = 'CoreDataConnector::Item'
        SQL
      end

      def transform
        super

        execute <<-SQL.squish
          UPDATE #{table_name} z_items
             SET item_id = items.id
            FROM core_data_connector_items items
           WHERE items.uuid = z_items.uuid
        SQL
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
          name: 'item_id',
          type: 'INTEGER'
        }, {
          name: 'user_defined',
          type: 'JSONB'
        }]
      end
    end
  end
end