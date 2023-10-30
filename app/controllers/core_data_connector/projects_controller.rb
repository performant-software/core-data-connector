module CoreDataConnector
  class ProjectsController < ApplicationController
    # Search attributes
    search_attributes :name

    protected

    # If we're not looking for "discoverable" projects, use base query defined by the policy. Otherwise, return
    # a query to find all discoverable projects not matching the current project.
    def base_query
      return super unless params[:discoverable].to_s.to_bool && params[:project_id].present?

      Project
        .where(discoverable: true)
        .where.not(id: params[:project_id])
    end

    # Automatically add the user who created the project as the owner, if they are not an admin.
    def after_create(project)
      return if current_user.admin?

      UserProject.create(
        project_id: project.id,
        user_id: current_user.id,
        role: UserProject::ROLE_OWNER
      )
    end
  end
end