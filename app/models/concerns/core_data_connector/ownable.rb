module CoreDataConnector
  module Ownable
    extend ActiveSupport::Concern

    included do
      delegate :project_id, to: :project_model, allow_nil: true
    end
  end
end