module CoreDataConnector
  class NamesController < ApplicationController
    # Search attributes
    search_attributes :name

    def base_query
      query = super

      return query.none unless params[:project_id] && params[:nameable_model]

      nameable_model = "CoreDataConnector::#{params[:nameable_model].classify}".constantize
      polymorphic_table_class = "CoreDataConnector::#{nameable_model.get_names_table.to_s.classify}".constantize

      query
        .where(
          polymorphic_table_class
            .where(polymorphic_table_class.arel_table[:name_id].eq(CoreDataConnector::Name.arel_table[:id]))
            .arel
            .exists
        )
        .where(
          nameable_model
            .joins(nameable_model.get_names_table.to_sym => :name)
            .joins(:project_model)
            .where(
              CoreDataConnector::ProjectModel.arel_table[:project_id].eq(params[:project_id])
            )
            .arel
            .exists
        )
    end
  end
end
