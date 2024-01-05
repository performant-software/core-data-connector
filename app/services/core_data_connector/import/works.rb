module CoreDataConnector
  module Import
    class Works < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE
          core_data_connector_works
            SET z_work_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_works works
             SET z_work_id = z_works.id,
                 user_defined = z_works.user_defined,
                 updated_at = current_timestamp
            FROM #{table_name} z_works
           WHERE z_works.work_id = works.id
        SQL

        execute <<-SQL.squish
        WITH

        insert_works AS (
          INSERT INTO core_data_connector_works (
            project_model_id,
            uuid,
            z_work_id,
            user_defined,
            created_at,
            updated_at
          )
          SELECT z_works.project_model_id, 
                 z_works.uuid, 
                 z_works.id, 
                 z_works.description, 
                 z_works.user_defined, 
                 current_timestamp, 
                 current_timestamp
          FROM #{table_name} z_works
          WHERE z_works.work_id IS NULL
          RETURNING id AS work_id, z_work_id

        ),

        insert_names AS (
          INSERT INTO core_data_connector_names
            (name, created_at, updated_at)
          SELECT insert_works.name, current_timestamp, current_timestamp
          FROM insert_works
          JOIN #{table_name} z_works ON z_works.id = insert_works.z_work_id
          RETURNING id
        )

        INSERT INTO core_data_connector_source_titles
          (nameable_type, nameable_id, name_id, primary, created_at, updated_at)
          VALUES
          (
            "CoreDataConnector::Work",
            insert_works.work_id,
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
          UPDATE #{table_name} z_works
            SET work_id = works.id
            FROM core_data_connector_works works
            WHERE works.uuid = z_works.uuid
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
          name: 'work_id',
          type: 'INTEGER'
        }, {
          name: 'user_defined',
          type: 'JSONB'
        }]
      end
    end
  end
end