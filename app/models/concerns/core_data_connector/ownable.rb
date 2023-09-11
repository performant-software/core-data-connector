module CoreDataConnector
  module Ownable
    extend ActiveSupport::Concern

    included do
      # Relationships
      has_one :project_item, as: :ownable, dependent: :destroy

      # Nested attributes
      accepts_nested_attributes_for :project_item, allow_destroy: true
    end
  end
end