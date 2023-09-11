module CoreDataConnector
  module OwnableSerializer
    extend ActiveSupport::Concern

    included do
      index_attributes project_item: [:project_id, project: ProjectsSerializer]
      show_attributes project_item: [:project_id, project: ProjectsSerializer]
    end
  end
end