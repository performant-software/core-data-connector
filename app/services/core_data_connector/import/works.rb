module CoreDataConnector
  module Import
    class Works < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_works
            SET z_work_id = NULL
        SQL

        execute <<-SQL.squish
          VACUUM ANALYZE core_data_connector_works, core_data_connector_source_names
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH
 
          update_works AS (

          UPDATE core_data_connector_works works
             SET z_work_id = z_works.id,
                 user_defined = z_works.user_defined,
                 import_id = z_works.import_id,
                 updated_at = current_timestamp
            FROM #{table_name} z_works
           WHERE z_works.work_id = works.id

          )

          UPDATE core_data_connector_source_names source_names
             SET name = z_works.name
            FROM #{table_name} z_works
           WHERE z_works.work_id = source_names.nameable_id
             AND source_names.nameable_type = 'CoreDataConnector::Work'
             AND source_names.primary = TRUE
        SQL

        execute <<-SQL.squish
        WITH

        insert_works AS (

        INSERT INTO core_data_connector_works (
          project_model_id,
          uuid,
          z_work_id,
          user_defined,
          import_id,
          created_at,
          updated_at
        )
        SELECT z_works.project_model_id,
               z_works.uuid,
               z_works.id,
               z_works.user_defined,
               z_works.import_id,
               current_timestamp,
               current_timestamp
          FROM #{table_name} z_works
         WHERE z_works.work_id IS NULL
        RETURNING id AS work_id, z_work_id

        )

        INSERT INTO core_data_connector_source_names (
          nameable_id,
          nameable_type,
          name,
          "primary",
          created_at,
          updated_at
        )
        SELECT insert_works.work_id,
               'CoreDataConnector::Work',
               z_works.name,
               TRUE,
               current_timestamp,
               current_timestamp
          FROM insert_works
          JOIN #{table_name} z_works ON z_works.id = insert_works.z_work_id
        SQL
      end

      def transform
        execute <<-SQL.squish
          UPDATE #{table_name} z_works
             SET work_id = works.id,
                 user_defined = works.user_defined
            FROM core_data_connector_works works
           WHERE works.uuid = z_works.uuid
             AND z_works.uuid IS NOT NULL
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
          name: 'work_id',
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
        'z_works'
      end
    end
  end
end
