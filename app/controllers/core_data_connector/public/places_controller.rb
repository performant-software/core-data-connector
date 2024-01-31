module CoreDataConnector
  module Public
    class PlacesController < PublicController
      # Includes
      include NameableController
      include UnauthenticateableController
      include UserDefinedFields::Queryable

      # Preloads
      preloads :place_names, only: :show
      preloads :place_geometry
      preloads project_model: :user_defined_fields

      # Search attributes
      search_attributes :name
    end
  end
end
