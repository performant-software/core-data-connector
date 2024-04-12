module CoreDataConnector
  class WebAuthoritiesController < ApplicationController
    # Search attributes
    search_attributes :source_type

    def find
      render json: { errors: [I18n.t('errors.web_authorities_controller.find.identifier')] }, status: :bad_request and return unless params[:identifier].present?

      authority = WebAuthority.find(params[:id])
      authorize authority, :search?

      instance = Authority::Base.create_service(authority)
      json = instance.find(params[:identifier], authority.access&.symbolize_keys)

      render json: json, status: :ok
    end

    def search
      render json: { errors: [I18n.t('errors.web_authorities_controller.search.query')] }, status: :bad_request and return unless params[:query].present?

      authority = WebAuthority.find(params[:id])
      authorize authority, :find?

      instance = Authority::Base.create_service(authority)
      json = instance.search(params[:query], authority.access&.symbolize_keys)

      render json: json, status: :ok
    end

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