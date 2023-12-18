module CoreDataConnector
  class NamesController < ApplicationController
    # Search attributes
    search_attributes :name

    def base_query
      query = super

      return query.none unless params[:project_id]

      nameable_models = [
        :instance,
        :item,
        :work
      ]

      queries = nameable_models.map do |nm|
        model_name = "CoreDataConnector::#{nm.to_s.classify}".constantize

        CoreDataConnector::SourceTitle
          .joins(nm => :project_model)
          .where(
            CoreDataConnector::ProjectModel.arel_table[:project_id].eq(params[:project_id])
            )
          .where(CoreDataConnector::SourceTitle.arel_table[:nameable_type].eq(model_name))
          .where(CoreDataConnector::SourceTitle.arel_table[:name_id].eq(CoreDataConnector::Name.arel_table[:id]))
      end

      raw_sql = <<-SQL.squish
        EXISTS (
          #{queries[0].to_sql}
          UNION
          #{queries[1].to_sql}
          UNION
          #{queries[2].to_sql}
        )
      SQL

      query
        .where(raw_sql)
    end
  end
end
