class AddArchivedToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_projects, :archived, :boolean, default: false, null: false
  end
end
