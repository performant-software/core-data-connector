module CoreDataConnector
  class OrganizationsController < ApplicationController
    # Includes
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads :organization_names, only: :show

    # Search attributes
    search_attributes :name
  end
end