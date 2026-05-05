module CoreDataConnector
  module ManifestableController
    extend ActiveSupport::Concern

    included do

      def create_manifests
        item = find_record(item_class)
        authorize item

        Job.create_iiif_manifest_job!(item, params[:project_model_relationship_id], current_user)

        render status: :ok
      end

    end
  end
end