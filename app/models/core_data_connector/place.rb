module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Relationships
    has_many :place_names, dependent: :destroy
    has_one :primary_name, -> { where(primary: true) }, class_name: 'PlaceName'

    # Nested attributes
    accepts_nested_attributes_for :place_names, allow_destroy: true

    # Resourceable parameters
    allow_params place_names_attributes: [:id, :name, :primary, :_destroy]

    def name
      primary_name&.name
    end
  end
end
