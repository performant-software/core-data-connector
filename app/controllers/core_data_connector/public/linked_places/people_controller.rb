module CoreDataConnector
  module Public
    module LinkedPlaces
      class PeopleController < LinkedPlacesController
        # Includes
        include NameableController
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Joins
        joins :primary_name

        # Preloads
        preloads :person_names
        preloads :primary_name

        # Search attributes
        search_attributes :first_name, :middle_name, :last_name
      end
    end
  end
end