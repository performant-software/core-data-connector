module CoreDataConnector
  class ProjectModelRelationship < ApplicationRecord
    # Includes
    include Sluggable
    include UserDefinedFields::Defineable

    # Relationships
    belongs_to :primary_model, class_name: ProjectModel.to_s
    belongs_to :related_model, class_name: ProjectModel.to_s
    has_many :relationships, dependent: :destroy

    # Delegates
    delegate :project_id, to: :primary_model

    # Validations
    validates :name, presence: true
    validates :inverse_name, presence: true, if: :allow_inverse?
  end
end