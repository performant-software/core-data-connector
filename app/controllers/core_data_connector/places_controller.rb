module CoreDataConnector
  class PlacesController < ApplicationController
    # Includes
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads :place_names, :place_geometry, only: :show

    # Search attributes
    search_attributes :name
  end
end
