module CoreDataConnector
  module Ownable
    extend ActiveSupport::Concern

    included do
      # Relationships
      belongs_to :project_model

      # Delegates
      delegate :project_id, to: :project_model, allow_nil: true
    end
  end
end