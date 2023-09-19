module CoreDataConnector
  class PeopleController < ApplicationController
    # Includes
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :first_name, :middle_name, :last_name
  end
end