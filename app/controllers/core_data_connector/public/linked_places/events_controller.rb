module CoreDataConnector
  module Public
    module LinkedPlaces
      class EventsController < LinkedPlacesController
        # Includes
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Preloads
        preloads project_model: :user_defined_fields
        preloads :start_date, :end_date

        # Joins
        joins Event.start_date_join, Event.end_date_join

        # Search attributes
        search_attributes :name, :description
      end
    end
  end
end