module CoreDataConnector
  module Public
    class WorksController < PublicController
      # Includes
      include NameableController
      include UnauthenticateableController
      include UserDefinedFields::Queryable

      # Preloads
      preloads source_titles: :name
      preloads project_model: :user_defined_fields

      # Joins
      joins primary_name: :name
    end
  end
end