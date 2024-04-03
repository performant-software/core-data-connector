module CoreDataConnector
  class ProjectsSerializer < BaseSerializer
    index_attributes :id, :name, :description, :discoverable, :faircopy_cloud_url, :faircopy_cloud_project_model_id
    show_attributes :id, :name, :description, :discoverable, :faircopy_cloud_url, :faircopy_cloud_project_model_id
  end
end