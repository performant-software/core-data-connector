module CoreDataConnector
  module Import
    class Organizations < Base
      protected

      def column_names
        [{
           name: 'organization_id',
           type: 'INTEGER'
        }, {
           name: 'name',
           type: 'VARCHAR',
           copy: true
         }, {
           name: 'description',
           type: 'TEXT',
           copy: true
         }]
      end

      def load
        execute <<-SQL.squish
          WITH 
          
          insert_organizations AS (

          INSERT INTO core_data_connector_organizations (project_model_id, z_organization_id, description, user_defined, created_at, updated_at)
          SELECT z_organizations.project_model_id, z_organizations.id, description, user_defined, current_timestamp, current_timestamp
            FROM #{table_name} z_organizations
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

        execute <<-SQL.squish
          UPDATE core_data_connector_organizations
             SET z_organization_id = NULL
        SQL
      end

      def table_name_prefix
        'z_organizations'
      end
    end
  end
end