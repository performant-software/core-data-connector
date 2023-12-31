module CoreDataConnector
  class UserProjectsController < ApplicationController
    # Search attributes
    search_attributes 'users.name', 'users.email', 'projects.name', 'projects.description'

    # Joins
    joins :user, :project

    # Preloads
    preloads :user, :project

    protected

    def base_query
      return super if params[:id].present?

      query = super

      # User projects are only visible in the context of a user or a project.
      if params[:project_id].present?
        query.where(project_id: params[:project_id])
      elsif params[:user_id].present?
        query.where(user_id: params[:user_id])
      else
        query.none
      end
    end
  end
end