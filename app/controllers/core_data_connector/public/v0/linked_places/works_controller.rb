module CoreDataConnector
  module Public
    module V0
      module LinkedPlaces
        class WorksController < LinkedPlacesController
          # Includes
          include NameableController
          include UnauthenticateableController
          include UserDefinedFields::Queryable

          # Joins
          joins :primary_name

          # Preloads
          preloads primary_name: :name
          preloads project_model: :user_defined_fields
          preloads source_titles: :name
        end
      end
    end
  end
end