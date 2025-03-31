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
        search_attribute :name

        search_attribute(:names, facet: true) do
          place_names.map(&:name)
        end

        search_attribute(:geometry) do |place, polygons|
          if polygons
            next Geometry.to_geojson(place_geometry&.geometry)
          elsif self.respond_to?(:geometry_center) && geometry_center.present?
            next Geometry.to_geojson(geometry_center)
          end
        end

        search_attribute(:coordinates) do
          # Return if the "geometry_center" attribute is not defined
          next unless self.respond_to?(:geometry_center) && geometry_center.present?

          [geometry_center.y, geometry_center.x]
        end
      end
    end
  end
end