module CoreDataConnector
  class NamesController < ApplicationController
    # Search attributes
    search_attributes :name

    def base_query
      query = super

      return query.none unless params[:project_id] && params[:nameable_model]

      nameable_table = params[:nameable_model].to_sym
      nameable_model = "CoreDataConnector::#{params[:nameable_model].classify}".constantize

      polymorphic_table = nameable_model.get_names_table
      polymorphic_table_class = "CoreDataConnector::#{polymorphic_table.to_s.classify}".constantize

      query
        .where(
          polymorphic_table_class
            .joins(nameable_table.to_s.singularize.to_sym => :project_model)
            .where(
              CoreDataConnector::ProjectModel.arel_table[:project_id].eq(params[:project_id])
              )
            .where(polymorphic_table_class.arel_table[:nameable_type].eq(nameable_model.to_s))
            .where(polymorphic_table_class.arel_table[:name_id].eq(CoreDataConnector::Name.arel_table[:id]))
            .arel
            .exists
        )
    end
  end
end
