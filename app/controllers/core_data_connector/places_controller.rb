module CoreDataConnector
  class PlacesController < ApplicationController
    # Includes
    include NameableController
    include OwnableController

    # Search attributes
    search_attributes :name
  end
end
