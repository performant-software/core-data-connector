module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Includes
    include Export::Place
    include Identifiable
    include ImportAnalyze::Place
    include Manifestable
    include Mergeable
    include Nameable
    include Ownable
    include Relateable
    include Search::Place
    include UserDefinedFields::Fieldable

    # Relationships
    has_one :place_geometry, dependent: :destroy
    has_many :place_layers, dependent: :destroy

    # Nested attributes
    accepts_nested_attributes_for :place_geometry, allow_destroy: true
    accepts_nested_attributes_for :place_layers, allow_destroy: true

    # Nameable table
    name_table :place_names

    # Delegates
    delegate :name, to: :primary_name, allow_nil: true

    # User defined fields parent
    resolve_defineable -> (place) { place.project_model }

    def self.centroid_function
      function = Arel::Nodes::NamedFunction.new(
        'st_centroid',
        [PlaceGeometry.arel_table[:geometry]]
      ).as('geometry_center')
    end

    def self.with_centroid
      left_joins(:place_geometry)
        .select(arel_table[Arel.star], with_centroid_function)
    end

    def self.simplified_geometry_function(tolerance = 0.01)
      function = Arel::Nodes::NamedFunction.new(
        'st_simplify',
        [PlaceGeometry.arel_table[:geometry], Arel::Nodes.build_quoted(tolerance)]
      ).as('simplified_geometry')

      function
    end

    def self.with_search_geometry(simplify_tolerance = 0.01)
      left_joins(:place_geometry)
        .select(
          arel_table[Arel.star],
          centroid_function,
          simplified_geometry_function
        )
    end
  end
end
