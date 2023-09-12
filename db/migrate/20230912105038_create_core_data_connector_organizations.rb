class CreateCoreDataConnectorOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :core_data_connector_organizations do |t|
      t.text :description
      t.timestamps
    end
  end
end
