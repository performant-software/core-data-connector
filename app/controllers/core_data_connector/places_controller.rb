module CoreDataConnector
  class PlacesController < ApplicationController
    # Includes
    include MergeableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads :place_names, :place_geometry, :place_layers, only: :show

    # Search attributes
    search_attributes :name
  end
end
