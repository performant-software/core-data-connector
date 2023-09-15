class RemoveProjectItems < ActiveRecord::Migration[7.0]
  def change
    drop_table :core_data_connector_project_items
  end
end
