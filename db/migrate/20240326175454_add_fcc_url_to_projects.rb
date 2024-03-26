class AddFccUrlToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :core_data_connector_projects, :faircopy_cloud_url, :string
  end
end
