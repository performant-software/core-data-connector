module CoreDataConnector
  module Public
    class OrganizationsController < ApplicationController
      # Includes
      include NameableController
      include OwnableController
      include RelateableController
      include UnauthenticateableController
      include UserDefinedFields::Queryable

      # Preloads
      preloads :organization_names, only: :show

      # Search attributes
      search_attributes :name, :description
    end
  end
end