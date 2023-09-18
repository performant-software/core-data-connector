module CoreDataConnector
  class Relationship < ApplicationRecord
    belongs_to :project_model_relationship
    belongs_to :primary_record, polymorphic: true
    belongs_to :related_record, polymorphic: true

    delegate :project_id, to: :project_model_relationship
  end
end