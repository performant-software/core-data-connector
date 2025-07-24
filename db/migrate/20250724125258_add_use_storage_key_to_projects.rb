class AddUseStorageKeyToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :core_data_connector_projects, :use_storage_key, :boolean, default: false, null: false
  end
end
