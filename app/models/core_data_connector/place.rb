module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Includes
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable

    # Relationships
    has_one :place_geometry, dependent: :destroy

    # Nested attributes
    accepts_nested_attributes_for :place_geometry, allow_destroy: true

    # Delegates
    delegate :name, to: :primary_name

    # User defined fields parent
    resolve_defineable -> (place) { place.project_model }
  end
end
