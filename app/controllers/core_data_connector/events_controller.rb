module CoreDataConnector
  class EventsController < ApplicationController
    # Includes
    include OwnableController

    # Search attributes
    search_attributes :name, :description
  end
end