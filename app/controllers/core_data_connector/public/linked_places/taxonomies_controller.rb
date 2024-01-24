module CoreDataConnector
  module Public
    module LinkedPlaces
      class TaxonomiesController < LinkedPlacesController
        # Includes
        include UnauthenticateableController

        # Search attributes
        search_attributes :name
      end
    end
  end
end