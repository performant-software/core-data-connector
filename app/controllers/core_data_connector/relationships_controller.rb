module CoreDataConnector
  class RelationshipsController < ApplicationController
    protected

    def base_query
      # If we're accessing a single record, do not apply any additional filtering. We'll assume the policy is set up
      # such that the correct access is granted.
      return super if params[:id].present?

      # For an index view, scope the list of relationships to those owned by the project_model_relationship,
      # for the given record type.
      required_params = %i(project_model_relationship_id primary_record_id primary_record_type)
      return Relationship.none unless required_params.all?{ |p| params[p].present? }

      Relationship.where(
        project_model_relationship_id: params[:project_model_relationship_id],
        primary_record_id: params[:primary_record_id],
        primary_record_type: params[:primary_record_type]
      )
    end
  end
end