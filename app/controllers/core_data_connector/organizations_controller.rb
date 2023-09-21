module CoreDataConnector
  class OrganizationsController < ApplicationController
    # Includes
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :name
  end
end