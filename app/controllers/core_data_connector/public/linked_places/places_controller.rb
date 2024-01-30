module CoreDataConnector
  module Public
    module LinkedPlaces
      class PlacesController < LinkedPlacesController
        # Includes
        include NameableController
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Joins
        joins :primary_name

        # Preloads
        preloads :primary_name
        preloads :place_names, :place_geometry, :place_layers

        # Search attributes
        search_attributes :name
      end
    end
  end
end