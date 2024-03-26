class AddFccIdToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_items, :faircopy_cloud_id, :string
  end
end
