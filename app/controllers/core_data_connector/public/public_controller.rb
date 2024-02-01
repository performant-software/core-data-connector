module CoreDataConnector
  module Public
    class PublicController < ApplicationController
      # Member attributes
      attr_reader :current_record

      # Actions
      before_action :set_current_record

      protected

      def base_query
        if nested_resource?
          item_class.where(build_base_sql)
        elsif params[:project_ids].present?
          item_class.all_records_by_project(params[:project_ids])
        else
          item_class.none
        end
      end

      def load_records(item)
        { nested_resource: nested_resource? }
      end

      def nested_resource?
        return true if current_record.present? && params[:project_ids].present?

        false
      end

      # Preloads the relationships records scoped to the passed project_ids
      def preloads(query)
        super

        return unless nested_resource?

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
        "CoreDataConnector::Public::#{"#{controller_name}_serializer".classify}".constantize
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

      def set_current_record
        if params[:instance_id].present?
          @current_record = Instance.find_by_uuid(params[:instance_id])
        elsif params[:item_id].present?
          @current_record = Item.find_by_uuid(params[:item_id])
        elsif params[:place_id].present?
          @current_record = Place.find_by_uuid(params[:place_id])
        elsif params[:work_id].present?
          @current_record = Work.find_by_uuid(params[:work_id])
        end
      end
    end
  end
end