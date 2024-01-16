module CoreDataConnector
  class WebAuthoritiesController < ApplicationController
    # Search attributes
    search_attributes :source_type

    protected

    def base_query
      # Return the super method if an "id" is provided
      return super if params[:id].present?

      # For index routes, require the project_id to be provided
      return WebAuthority.none unless params[:project_id].present?

      WebAuthority.where(project_id: params[:project_id])
    end
  end
end