class AddZOrganizationIdToCoreDataConnectorOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_organizations, :z_organization_id, :integer
  end
end
