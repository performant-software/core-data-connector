module CoreDataConnector
  class ProjectModelRelationship < ApplicationRecord
    # Relationships
    belongs_to :primary_model, class_name: ProjectModel.to_s
    belongs_to :related_model, class_name: ProjectModel.to_s

    # Validations
    validates :name, presence: true
  end
end