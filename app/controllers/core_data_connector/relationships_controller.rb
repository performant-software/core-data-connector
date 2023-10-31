module CoreDataConnector
  class RelationshipsController < ApplicationController
    # Includes
    include Api::Uploadable
    include UserDefinedFields::Queryable

    # Actions
    before_action :set_project_model_relationship, only: :index

    # Search methods
    search_methods :search_related_records

    protected

    def base_query
      # If we're accessing a single record, do not apply any additional filtering. We'll assume the policy is set up
      # such that the correct access is granted.
      return super if params[:id].present?

      # For an index view, scope the list of relationships to those owned by the project_model_relationship,
      # for the given record type.
      return Relationship.none unless params[:project_model_relationship_id].present? && params[:record_id].present? && params[:record_type].present?

      # Relationships should always to scoped to a project model relationship. For inverse relationships, we'll
      # use the related record.
      if params[:inverse]
        query = Relationship.where(
          project_model_relationship_id: params[:project_model_relationship_id],
          related_record_id: params[:record_id],
          related_record_type: params[:record_type]
        )
      else
        query = Relationship.where(
          project_model_relationship_id: params[:project_model_relationship_id],
          primary_record_id: params[:record_id],
          primary_record_type: params[:record_type]
        )
      end

      # For sorting, left join the polymorphic model we're currently looking at.
      case model_class
      when MediaContent.to_s
        query = query.joins(params[:inverse] ? :inverse_related_media_content : :related_media_content)
      when Organization.to_s
        query = query.joins(params[:inverse] ? { inverse_related_organization: :primary_name } : { related_organization: :primary_name })
      when Person.to_s
        query = query.joins(params[:inverse] ? { inverse_related_person: :primary_name } : { related_person: :primary_name })
      when Place.to_s
        query = query.joins(params[:inverse] ? { inverse_related_place: :primary_name } : { related_place: :primary_name })
      end

      query
    end

    private

    # Returns the related model class for filtering and sorting.
    def model_class
      if params[:inverse]
        @project_model_relationship.primary_model.model_class
      else
        @project_model_relationship.related_model.model_class
      end
    end

    def resolve_person_query
      query = nil

      table = PersonName.arel_table
      table_name = table.name

      attributes = [
        "#{table_name}.#{table[:last_name].name}",
        "#{table_name}.#{table[:first_name].name}",
        "#{table_name}.#{table[:first_name].name} || ' ' || #{table_name}.#{table[:last_name].name}"
      ]

      attributes.each do |attr|
        q = resolve_search_query(attr)

        if query.nil?
          query = q
        else
          query = query.or(q)
        end
      end

      query
    end

    def search_related_records(query)
      or_query = nil

      case model_class
      when MediaContent.to_s
        attribute = "#{MediaContent.arel_table.name}.#{MediaContent.arel_table[:name].name}"
        or_query = resolve_search_query(attribute)
      when Organization.to_s
        attribute = "#{OrganizationName.arel_table.name}.#{OrganizationName.arel_table[:name].name}"
        or_query = resolve_search_query(attribute)
      when Person.to_s
        or_query = resolve_person_query
      when Place.to_s
        attribute = "#{PlaceName.arel_table.name}.#{PlaceName.arel_table[:name].name}"
        or_query = resolve_search_query(attribute)
      end

      return query if or_query.nil?

      if query == item_class.all
        query.merge(or_query)
      else
        query.or(or_query)
      end
    end

    def set_project_model_relationship
      @project_model_relationship = ProjectModelRelationship.find(params[:project_model_relationship_id])
    end
  end
end