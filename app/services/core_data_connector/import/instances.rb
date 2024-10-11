module CoreDataConnector
  module Import
    class Instances < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_instances
            SET z_instance_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH
 
          update_instances AS (

            UPDATE core_data_connector_instances instances
               SET z_instance_id = z_instances.id,
                   user_defined = z_instances.user_defined,
                   import_id = z_instances.import_id,
                   updated_at = current_timestamp
              FROM #{table_name} z_instances
             WHERE z_instances.instance_id = instances.id

          )

          UPDATE core_data_connector_source_names source_names
             SET name = z_instances.name
            FROM #{table_name} z_instances
           WHERE z_instances.instance_id = source_names.nameable_id
             AND source_names.nameable_type = 'CoreDataConnector::Instance'
             AND source_names.primary = TRUE
        SQL

        execute <<-SQL.squish
        WITH

        insert_instances AS (

        INSERT INTO core_data_connector_instances (
          project_model_id,
          uuid,
          z_instance_id,
          user_defined,
          import_id,
          created_at,
          updated_at
        )
        SELECT z_instances.project_model_id,
               z_instances.uuid,
               z_instances.id,
               z_instances.user_defined,
               z_instances.import_id,
               current_timestamp,
               current_timestamp
          FROM #{table_name} z_instances
         WHERE z_instances.instance_id IS NULL
        RETURNING id AS instance_id, z_instance_id

        )

        INSERT INTO core_data_connector_source_names (
          nameable_id,
          nameable_type,
          name,
          "primary",
          created_at,
          updated_at
        )
        SELECT insert_instances.instance_id, 
               'CoreDataConnector::Instance',
               z_instances.name,
               TRUE,
               current_timestamp,
               current_timestamp
          FROM insert_instances
          JOIN #{table_name} z_instances on z_instances.id = insert_instances.z_instance_id
        SQL
      end

      def transform
        super

        execute <<-SQL.squish
          UPDATE #{table_name} z_instances
             SET instance_id = instances.id
            FROM core_data_connector_instances instances
           WHERE instances.uuid = z_instances.uuid
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
          name: 'instance_id',
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
        'z_instances'
      end
    end
  end
end
