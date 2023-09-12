module CoreDataConnector
  class ProjectModelsController < ApplicationController
    # Search attributes
    search_attributes :name

    # Returns a list of valid model classes
    def model_classes
      classes = ProjectModel
                  .model_classes
                  .map(&:model_name)
                  .map{ |mn| { label: mn.human, value: mn.name } }

      render json: { model_classes: classes }, status: :ok
    end
  end
end