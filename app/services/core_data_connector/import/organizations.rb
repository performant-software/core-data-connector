module CoreDataConnector
  module Import
    class Organizations < Base
      def cleanup
        super

        execute <<-SQL.squish
          UPDATE core_data_connector_organizations
             SET z_organization_id = NULL
        SQL
      end

      def load
        super

        execute <<-SQL.squish
          WITH
          
          update_organizations AS (
          
          UPDATE core_data_connector_organizations organizations
             SET z_organization_id = z_organizations.id,
                 description = z_organizations.description,
                 user_defined = z_organizations.user_defined,
                 updated_at = current_timestamp
            FROM #{table_name} z_organizations
           WHERE z_organizations.organization_id = organizations.id

          )
          
          UPDATE core_data_connector_organization_names organization_names
             SET name = z_organizations.name,
                 updated_at = current_timestamp
            FROM #{table_name} z_organizations
           WHERE z_organizations.organization_id = organization_names.organization_id
             AND organization_names.primary = TRUE
        SQL

        execute <<-SQL.squish
          WITH 
          
          insert_organizations AS (

          INSERT INTO core_data_connector_organizations (
            project_model_id, uuid, 
            z_organization_id, 
            description, 
            user_defined, 
            created_at, 
            updated_at
            )
          SELECT z_organizations.project_model_id, 
                 z_organizations.uuid, 
                 z_organizations.id, 
                 z_organizations.description, 
                 z_organizations.user_defined, 
                 current_timestamp, 
                 current_timestamp
            FROM #{table_name} z_organizations
           WHERE z_organizations.organization_id IS NULL
          RETURNING id AS organization_id, z_organization_id

          ),

          insert_organization_names AS (

          INSERT INTO core_data_connector_organization_names (organization_id, name, "primary", created_at, updated_at)
          SELECT insert_organizations.organization_id, z_organizations.name, TRUE, current_timestamp, current_timestamp
            FROM insert_organizations
            JOIN #{table_name} z_organizations ON z_organizations.id = insert_organizations.z_organization_id
          RETURNING id

          )

          UPDATE #{table_name} z_organizations
             SET organization_id = insert_organizations.organization_id
            FROM insert_organizations
           WHERE insert_organizations.z_organization_id = z_organizations.id
        SQL
      end

      def transform
        super

        execute <<-SQL.squish
          UPDATE #{table_name} z_organizations
             SET uuid = gen_random_uuid()
           WHERE z_organizations.uuid IS NULL
        SQL

        execute <<-SQL.squish
          UPDATE #{table_name} z_organizations
             SET organization_id = organizations.id
            FROM core_data_connector_organizations organizations
           WHERE organizations.uuid = z_organizations.uuid
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
           name: 'description',
           type: 'TEXT',
           copy: true
         }, {
           name: 'organization_id',
           type: 'INTEGER'
         }, {
           name: 'user_defined',
           type: 'JSONB'
         }]
      end

      def table_name_prefix
        'z_organizations'
      end
    end
  end
end