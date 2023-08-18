module CoreDataConnector
  module Locateable
    extend ActiveSupport::Concern

    included do
      # Relationships
      has_many :locations, as: :locateable, dependent: :destroy, class_name: Location.to_s

      # Nested attributes
      accepts_nested_attributes_for :locations, allow_destroy: true

      # Resourceable parameters
      allow_params locations_attributes: [:id, :place_id, :_destroy]
    end
  end
end
