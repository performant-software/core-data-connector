module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Includes
    include Nameable
    include Ownable
    include Relateable
    include Search::Place
    include UserDefinedFields::Fieldable

    # Relationships
    has_one :place_geometry, dependent: :destroy

    # Nested attributes
    accepts_nested_attributes_for :place_geometry, allow_destroy: true

    name_table :place_names

    # Delegates
    delegate :name, to: :primary_name

    # User defined fields parent
    resolve_defineable -> (place) { place.project_model }

    def self.with_centroid
      function = Arel::Nodes::NamedFunction.new(
        'st_centroid',
        [PlaceGeometry.arel_table[:geometry]]
      ).as('geometry_center')

      left_joins(:place_geometry)
        .select(arel_table[Arel.star], function)
    end
  end
end
