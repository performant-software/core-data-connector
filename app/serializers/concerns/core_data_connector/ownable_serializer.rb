module CoreDataConnector
  module OwnableSerializer
    extend ActiveSupport::Concern

    included do
      index_attributes :project_model_id
      show_attributes :project_model_id
    end
  end
end