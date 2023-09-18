module CoreDataConnector
  class PeopleController < ApplicationController
    # Includes
    include NameableController
    include OwnableController

    # Search attributes
    search_attributes :last_name, :first_name, :middle_name
  end
end