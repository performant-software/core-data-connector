module CoreDataConnector
  module Public
    module LinkedPlaces
      class MediaContentsController < LinkedPlacesController
        # Includes
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Search attributes
        search_attributes :name
      end
    end
  end
end