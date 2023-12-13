class AddUserDefinedFieldsToCoreDataConnectorInstances < ActiveRecord::Migration[7.0]
  def up
    add_column :core_data_connector_instances, :user_defined, :jsonb, default: {}
    add_index :core_data_connector_instances, :user_defined, using: :gin
  end

  def down
    remove_index :core_data_connector_instances, :user_defined
    remove_column :core_data_connector_instances, :user_defined
  end
end
