module CoreDataConnector
  module Public
    module V1
      class WorksController < PublicController
        # Includes
        include NameableController
        include UnauthenticateableController
        include UserDefinedFields::Queryable

        # Preloads
        preloads source_titles: :name
        preloads project_model: :user_defined_fields
        preloads web_identifiers: :web_authority, only: :show

        # Joins
        joins primary_name: :name
      end
    end
  end
end