module CoreDataConnector
  class WebIdentifiersController < ApplicationController
    # Search attributes
    search_attributes :key

    # Preloads
    preloads :web_authority

    # Joins
    joins :web_authority

    protected

    def base_query
      # Return the super method if an "id" is provided
      return super if params[:id].present?

      # For index routes, require the identifiable_id and identifiable_type to be provided
      return WebIdentifier.none unless params[:identifiable_id].present? && params[:identifiable_type].present?

      WebIdentifier
        .where(identifiable_id: params[:identifiable_id])
        .where(identifiable_type: params[:identifiable_type])
    end
  end
end