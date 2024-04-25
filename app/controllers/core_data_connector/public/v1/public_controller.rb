module CoreDataConnector
  module Public
    module V1
      class PublicController < ApplicationController
        # Includes
        include NestableController

        protected

        def base_query
          return item_class.none unless params[:project_ids].present?

          if nested_resource?
            item_class.where(build_base_sql)
          elsif params[:project_ids].present?
            item_class.all_records_by_project(params[:project_ids])
          else
            item_class.none
          end
        end

        def build_index_response(items, metadata)
          options = load_records(items).merge({
            count: metadata[:count],
            page: metadata[:page],
            pages: metadata[:pages]
          })

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
          opts = super

          opts.merge({
            target: current_record,
            url: request.url,
            project_ids: params[:project_ids],
            nested_resource: nested_resource?
          })
        end

        # Preloads the relationships records scoped to the passed project_ids
        def preloads(query)
          super

          return unless nested_resource?

          primary_scope = Relationship
                            .joins(project_model_relationship: :related_model)
                            .where(
                              primary_record_type: item_class.to_s,
                              related_record_id: current_record.id,
                              related_record_type: current_record.class.to_s,
                              related_model: {
                                project_id: params[:project_ids]
                              },
                              project_model_relationship: {
                                allow_inverse: true
                              }
                            )

          if params[:project_model_relationship_uuid].present?
            primary_scope = primary_scope.where(project_model_relationship: {
              uuid: params[:project_model_relationship_uuid]
            })
          end

          Preloader.new(
            records: query,
            associations: [
              relationships: [
                project_model_relationship: :user_defined_fields
              ]
            ],
            scope: primary_scope
          ).call

          related_scope = Relationship
                            .joins(project_model_relationship: :primary_model)
                            .where(
                              related_record_type: item_class.to_s,
                              primary_record_id: current_record.id,
                              primary_record_type: current_record.class.to_s,
                              primary_model: {
                                project_id: params[:project_ids]
                              }
                            )

          if params[:project_model_relationship_uuid].present?
            related_scope = related_scope.where(project_model_relationship: {
              uuid: params[:project_model_relationship_uuid]
            })
          end

          Preloader.new(
            records: query,
            associations: [
              related_relationships: [project_model_relationship: :user_defined_fields]
            ],
            scope: related_scope
          ).call
        end

        def serializer_class
          "CoreDataConnector::Public::V1::#{"#{controller_name}_serializer".classify}".constantize
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
                              primary_model: {
                                project_id: params[:project_ids]
                              }
                            )

          if params[:project_model_relationship_uuid].present?
            primary_query = primary_query
                              .where(project_model_relationship: {
                                uuid: params[:project_model_relationship_uuid]
                              })
          end

          related_query = Relationship
                            .select(1)
                            .joins(project_model_relationship: :related_model)
                            .where(Relationship.arel_table[:primary_record_id].eq(item_class.arel_table[:id]))
                            .where(
                              primary_record_type: item_class.to_s,
                              related_record_id: current_record.id,
                              related_record_type: current_record.class.to_s,
                              related_model: {
                                project_id: params[:project_ids]
                              },
                              project_model_relationship: {
                                allow_inverse: true
                              }
                            )

          if params[:project_model_relationship_uuid].present?
            related_query = related_query
                              .where(project_model_relationship: {
                                uuid: params[:project_model_relationship_uuid]
                              })
          end

          <<-SQL.squish
            EXISTS (
              #{primary_query.to_sql}
              UNION
              #{related_query.to_sql}
            )
          SQL
        end
      end
    end
  end
end