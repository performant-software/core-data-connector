module CoreDataConnector
  module Search
    module Place
      extend ActiveSupport::Concern

      class_methods do
        def preloads
          [:primary_name, :place_names, :place_geometry]
        end
      end

      included do
        # Includes
        include Base

        # Search attributes
        search_attribute(:name) do
          primary_name.name
        end

        search_attribute(:names) do
          place_names.map(&:name)
        end

        search_attribute(:geometry) do
          Geometry.to_geojson(place_geometry&.geometry)
        end
      end

    end
  end
end