module CoreDataConnector
  class PlacesController < ApplicationController
    # Search attributes
    search_attributes 'core_data_connector_place_names.name'

    # Left joins
    left_joins :primary_name

    # Preloads
    preloads :primary_name
  end
end
