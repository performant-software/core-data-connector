module CoreDataConnector
  module Public
    module LinkedPlaces
      class OrganizationsController < LinkedPlacesController
        # Includes
        include NameableController
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Joins
        joins :primary_name

        # Preloads
        preloads :organization_names
        preloads :primary_name

        # Search attributes
        search_attributes :name, :description
      end
    end
  end
end