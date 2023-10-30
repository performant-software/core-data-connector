module CoreDataConnector
  class ProjectModelAccess < ApplicationRecord
    # Relationships
    belongs_to :project_model
    belongs_to :project
  end
end