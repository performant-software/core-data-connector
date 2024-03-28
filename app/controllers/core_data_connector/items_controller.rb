module CoreDataConnector
  class ItemsController < ApplicationController
    include ImportableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    preloads source_titles: :name

    joins primary_name: :name

    # TODO: Haven't tested this yet.
    def import_csvs(file)
      project = Project.find(params[:project_id])
      authorize project, :import_data?

      errors = import(file)

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end
end
