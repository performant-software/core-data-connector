module CoreDataConnector
  module Public
    module RelateableController
      extend ActiveSupport::Concern

      included do
        # Member attributes
        attr_reader :current_record

        # Actions
        before_action :set_current_record

        protected

        def base_query
          # If we're not in the context of a nested route, call the "super" method
          return super unless current_record.present?

          # Return no records if the appropriate parameters are not passed
          return item_class.none unless params_valid?

          item_class.where(build_base_sql)
        end

        def build_index_response(items, metadata)
          options = load_records(items).merge({ count: metadata[:count] })
          serializer = serializer_class.new(current_user, options)
          serializer.render_index(items)
        end

        def build_show_response(item)
          options = load_records(item)
          serializer = serializer_class.new(current_user, options)
          serializer.render_show(item)
        end

        # Sets the additional attributes that are needed in the serializer
        def load_records(items)
          options = {
            target: current_record,
            url: request.url,
            user_defined_fields: load_user_defined_fields
          }

          options
        end

        # Preloads the relationships records scoped to the passed project_ids
        def preloads(query)
          super

          return unless params_valid?

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
                  related_record_id: current_record.id,
                  related_record_type: current_record.class.to_s,
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
                  primary_record_id: current_record.id,
                  primary_record_type: current_record.class.to_s,
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
                              primary_record_id: current_record.id,
                              primary_record_type: current_record.class.to_s,
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
                              related_record_id: current_record.id,
                              related_record_type: current_record.class.to_s,
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

        def load_user_defined_fields
          return nil unless params[:project_ids].present?

          UserDefinedFields::UserDefinedField
            .where(table_name: item_class.to_s)
            .where(
              ProjectModel
                .where(ProjectModel.arel_table[:id].eq(UserDefinedFields::UserDefinedField.arel_table[:defineable_id]))
                .where(UserDefinedFields::UserDefinedField.arel_table[:defineable_type].eq(ProjectModel.to_s))
                .where(project_id: params[:project_ids])
                .arel
                .exists
            )
        end

        def params_valid?
          return false unless current_record.present?

          return false unless params[:project_ids].present?

          true
        end

        def set_current_record
          if params[:place_id].present?
            @current_record = (
              Place
                .preload(:primary_name)
                .find_by_uuid(params[:place_id])
            )
          end
        end
      end
    end
  end
end