module CoreDataConnector
  module Public
    module V1
      class ManifestsController < ApplicationController
        # Includes
        include NestableController
        include UnauthenticateableController

        # Disable pagination
        per_page 0

        protected

        def base_query
          # Manifests can only be retrieved for nested routes
          return Manifest.none unless current_record.present?

          # If not retrieving a single manifest, the project_ids parameter is required
          return Manifest.none unless params[:project_ids].present? || params[:id].present?

          query = Manifest
                    .joins(project_model_relationship: [:primary_model, :related_model])
                    .where(
                      manifestable_id: current_record.id,
                      manifestable_type: current_record.class.to_s
                    )

          if params[:project_ids].present?
            query = query.where(
              primary_model: {
                project_id: params[:project_ids]
              }
            ).or(
              query.where(related_model: {
                project_id: params[:project_ids]
              })
            )
          end

          query
        end

        def build_index_response(items, metadata)
          return {} if items.empty?

          service = TripleEyeEffable::Presentation.new

          service.create_collection(
            id: identifier,
            label: label,
            items: items.map{ |i| to_collection_item(i) }
          )
        end

        def build_show_response(item)
          item&.content
        end

        def find_record(query)
          query
            .joins(:project_model_relationship)
            .where(project_model_relationship: {
              uuid: params[:id]
            })
            .take
        end

        private

        def identifier
          route_name = current_record.class.model_name.route_key.singularize
          method_name = "public_v1_#{route_name}_manifests_path"

          router_helpers = Engine.routes.url_helpers
          pathname = router_helpers.send(method_name.to_sym, current_record.uuid)

          url = "#{ENV['HOSTNAME']}#{pathname}"

          parameters = {
            project_ids: params[:project_ids]
          }

          "#{url}?#{parameters.to_query}"
        end

        def label
          service = Iiif::Manifest.new
          service.find_label(current_record)
        end

        def to_collection_item(manifest)
          {
            id: "#{ENV['HOSTNAME']}/#{manifest.identifier}",
            type: 'Manifest',
            label: manifest.label,
            item_count: manifest.item_count,
            thumbnail: manifest.thumbnail
          }
        end
      end
    end
  end
end