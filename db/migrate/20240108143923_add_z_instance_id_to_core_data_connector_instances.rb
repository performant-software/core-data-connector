class AddZInstanceIdToCoreDataConnectorInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_instances, :z_instance_id, :integer
  end
end
