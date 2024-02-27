module CoreDataConnector
  module Search
    module Place
      extend ActiveSupport::Concern

      class_methods do
        def preloads
          [:primary_name, :place_names, :place_geometry]
        end

        def search_query(query)
          query.merge(self.with_centroid)
        end
      end

      included do
        # Includes
        include Base

        # Search attributes
        search_attribute(:name) do
          primary_name.name
        end

        search_attribute(:names, facet: true) do
          place_names.map(&:name)
        end

        search_attribute(:geometry) do
          Geometry.to_geojson(place_geometry&.geometry)
        end

        search_attribute(:coordinates) do
          # Since the "geometry_center" attribute is defined in the select statement above, ensure that it exists
          # before calling.
          next unless self.respond_to?(:geometry_center)

          # Return if the "geometry_center" attribute is not defined
          next unless geometry_center.present?

          [geometry_center.y, geometry_center.x]
        end
      end

    end
  end
end