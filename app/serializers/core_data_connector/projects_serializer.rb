module CoreDataConnector
  class ProjectsSerializer < BaseSerializer
    index_attributes :id, :name, :description, :discoverable, :faircopy_cloud_url
    show_attributes :id, :name, :description, :discoverable, :faircopy_cloud_url
  end
end