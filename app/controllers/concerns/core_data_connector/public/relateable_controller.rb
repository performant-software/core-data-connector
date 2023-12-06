module CoreDataConnector
  module Public
    module RelateableController
      extend ActiveSupport::Concern

      included do
        # Actions
        before_action :set_params

        protected

        def base_query
          # If we're not in the context of a nested route, call the "super" method
          return super unless params[:nested]

          # Return no records if the appropriate parameters are not passed
          return item_class.none unless params_valid?

          item_class.where(build_base_sql)
        end

        def preloads(query)
          super

          return unless params_valid?

          Preloader.new(
            records: query,
            associations: [
              project_model: :user_defined_fields
            ]
          ).call

          Preloader.new(
            records: query,
            associations: [
              relationships: [
                project_model_relationship: :user_defined_fields
              ]
            ],
            scope: (
              Relationship
                .joins(project_model_relationship: :related_model)
                .where(
                  primary_record_type: item_class.to_s,
                  related_record_id: params[:record_id],
                  related_record_type: params[:record_type],
                  core_data_connector_project_models: {
                    project_id: params[:project_ids]
                  },
                  core_data_connector_project_model_relationships: {
                    allow_inverse: true
                  }
                )
            )

          ).call

          Preloader.new(
            records: query,
            associations: [
              related_relationships: [project_model_relationship: :user_defined_fields]
            ],
            scope: (
              Relationship
                .joins(project_model_relationship: :primary_model)
                .where(
                  related_record_type: item_class.to_s,
                  primary_record_id: params[:record_id],
                  primary_record_type: params[:record_type],
                  core_data_connector_project_models: {
                    project_id: params[:project_ids]
                  }
                )
            )
          ).call
        end

        def serializer_class
          "CoreDataConnector::Public::#{item_class.to_s.demodulize.pluralize}Serializer".constantize
        end

        private

        def build_base_sql
          primary_query = Relationship
                            .select(1)
                            .joins(project_model_relationship: :primary_model)
                            .where(Relationship.arel_table[:related_record_id].eq(item_class.arel_table[:id]))
                            .where(
                              related_record_type: item_class.to_s,
                              primary_record_id: params[:record_id],
                              primary_record_type: params[:record_type],
                              core_data_connector_project_models: {
                                project_id: params[:project_ids]
                              }
                            )

          related_query = Relationship
                            .select(1)
                            .joins(project_model_relationship: :related_model)
                            .where(Relationship.arel_table[:primary_record_id].eq(item_class.arel_table[:id]))
                            .where(
                              primary_record_type: item_class.to_s,
                              related_record_id: params[:record_id],
                              related_record_type: params[:record_type],
                              core_data_connector_project_models: {
                                project_id: params[:project_ids]
                              },
                              core_data_connector_project_model_relationships: {
                                allow_inverse: true
                              }
                            )

          <<-SQL.squish
          EXISTS (
            #{primary_query.to_sql}
            UNION
            #{related_query.to_sql}
          )
        SQL
        end

        def params_valid?
          %i(record_id record_type project_ids).all?{ |p| params[p].present? }
        end

        def set_params
          if params[:place_id].present?
            params[:record_id] = params[:place_id]
            params[:record_type] = Place.to_s
            params[:nested] = true
          end
        end
      end
    end
  end
end