module CoreDataConnector
  module Import
    class Instances < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE
          core_data_connector_instances
            SET z_instance_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_instances instances
             SET z_instance_id = z_instances.id,
                 user_defined = z_instances.user_defined,
                 updated_at = current_timestamp
            FROM #{table_name} z_instances
           WHERE z_instances.instance_id = instances.id
        SQL

        execute <<-SQL.squish
        WITH

        insert_instances AS (
          INSERT INTO core_data_connector_instances (
            project_model_id,
            uuid,
            z_instance_id,
            user_defined,
            created_at,
            updated_at
          )
          SELECT z_instances.project_model_id, 
                 z_instances.uuid, 
                 z_instances.id, 
                 z_instances.description, 
                 z_instances.user_defined, 
                 current_timestamp, 
                 current_timestamp
          FROM #{table_name} z_instances
          WHERE z_instances.instance_id IS NULL
          RETURNING id AS instance_id, z_instance_id

        ),

        insert_names AS (
          INSERT INTO core_data_connector_names
            (name, created_at, updated_at)
          SELECT insert_instances.name, current_timestamp, current_timestamp
          FROM insert_instances
          JOIN #{table_name} z_instances ON z_instances.id = insert_instances.z_instance_id
          RETURNING id
        )

        INSERT INTO core_data_connector_source_titles
          (nameable_type, nameable_id, name_id, primary, created_at, updated_at)
          VALUES
          (
            "CoreDataConnector::Instance",
            insert_instances.instance_id,
            insert_names.id,
            TRUE,
            current_timestamp,
            current_timestamp
          )
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
        }]
      end
    end
  end
end