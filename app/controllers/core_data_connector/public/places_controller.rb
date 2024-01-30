module CoreDataConnector
  module Public
    class PlacesController < ApplicationController
      # Includes
      include NameableController
      include OwnableController
      include RelateableController
      include UnauthenticateableController
      include UserDefinedFields::Queryable

      # Preloads
      preloads :place_names, :place_geometry, :place_layers, only: :show

      # Search attributes
      search_attributes :name
    end
  end
end