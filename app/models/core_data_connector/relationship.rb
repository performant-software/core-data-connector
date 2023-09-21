module CoreDataConnector
  class Relationship < ApplicationRecord
    # Includes
    include UserDefinedFields::Fieldable

    # Relationships
    belongs_to :project_model_relationship
    belongs_to :primary_record, polymorphic: true
    belongs_to :related_record, polymorphic: true

    # Delegates
    delegate :project_id, to: :project_model_relationship

    # User defined fields parent
    resolve_defineable -> (relationship) { relationship.project_model_relationship }
  end
end