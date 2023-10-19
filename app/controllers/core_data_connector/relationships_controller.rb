module CoreDataConnector
  class RelationshipsController < ApplicationController
    # Includes
    include Api::Uploadable
    include UserDefinedFields::Queryable

    # Actions
    before_action :set_project_model_relationship, only: :index

    protected

    def base_query
      # If we're accessing a single record, do not apply any additional filtering. We'll assume the policy is set up
      # such that the correct access is granted.
      return super if params[:id].present?

      # For an index view, scope the list of relationships to those owned by the project_model_relationship,
      # for the given record type.
      required_params = %i(project_model_relationship_id primary_record_id primary_record_type)
      return Relationship.none unless required_params.all?{ |p| params[p].present? }

      #
      query = Relationship.where(
        project_model_relationship_id: params[:project_model_relationship_id],
        primary_record_id: params[:primary_record_id],
        primary_record_type: params[:primary_record_type]
      )

      # For sorting, left join the polymorphic model we're currently looking at
      case @project_model_relationship.related_model.model_class
      when MediaContent.to_s
        query = query.joins(:related_media_content)
      when Organization.to_s
        query = query.joins(related_organization: :primary_name)
      when Person.to_s
        query = query.joins(related_person: :primary_name)
      when Place.to_s
        query = query.joins(related_place: :primary_name)
      end

      query
    end

    private

    def set_project_model_relationship
      @project_model_relationship = ProjectModelRelationship.find(params[:project_model_relationship_id])
    end
  end
end