module CoreDataConnector
  class ProjectModelsController < ApplicationController
    # Search attributes
    search_attributes :name

    # Preloads
    preloads :project_model_relationships

    # Returns a list of valid model classes
    def model_classes
      classes = ProjectModel
                  .model_classes
                  .map(&:model_name)
                  .map{ |mn| { label: mn.human, value: mn.name } }

      render json: { model_classes: classes }, status: :ok
    end

    protected

    # Project settings cannot be viewed outside the context of a project
    def base_query
      if params[:id].present?
        ProjectModel.where(id: params[:id])
      elsif params[:project_id].present?
        ProjectModel.where(project_id: params[:project_id])
      else
        ProjectModel.none
      end
    end
  end
end