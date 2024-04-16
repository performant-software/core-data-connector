module CoreDataConnector
  class EventsController < ApplicationController
    # Includes
    include OwnableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :name, :description
  end
end