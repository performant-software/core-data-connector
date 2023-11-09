module CoreDataConnector
  class ProjectsSerializer < BaseSerializer
    index_attributes :id, :name, :description, :discoverable
    show_attributes :id, :name, :description, :discoverable
  end
end