module CoreDataConnector
  module ManifestsController
    extend ActiveSupport::Concern

    # This module should be included in the relationships_controller in order to handle generating IIIF manifests
    # after records are added/removed.
    included do
      # Actions
      after_action :update_manifests_on_upload, only: :upload
      after_action :update_manifests_on_delete, only: :destroy
      before_action :set_record_for_manifest, only: :destroy

      private

      # Returns the record to update the manifest for the passed relationship.
      def record_to_update(relationship)
        if relationship.related_record_type == MediaContent.to_s
          record = relationship.primary_record
        elsif relationship.primary_record_type == MediaContent.to_s && relationship.project_model_relationship.allow_inverse?
          record = relationship.related_record
        end

        # Only create manifests for models that include the Manifestale concern
        return nil unless record.is_a?(Manifestable)

        record
      end

      # For deleting a relationship, we'll track the record and project_model_relationship_id in the before_action,
      # since the relationship wont exist after.
      def set_record_for_manifest
        relationship = Relationship.find(params[:id])
        @record = record_to_update(relationship)
        @project_model_relationship_id = relationship.project_model_relationship_id
      end

      # After the relationship has been deleted, re-create the manifest for the target model.
      def update_manifests_on_delete
        return if @record.nil? || @project_model_relationship_id.nil?

        service = Iiif::Manifest.new
        service.reset_manifests_by_type(@record.class, {
          id: @record.id,
          project_model_relationship_id: @project_model_relationship_id
        })
      end

      # After uploading new relationships, generate the manifests for the target models.
      def update_manifests_on_upload
        cache = []

        params[:relationships].keys.each do |index|
          relationship_params = params[:relationships][index]

          relationship = Relationship.find_by(
            primary_record_id: relationship_params[:primary_record_id],
            primary_record_type: relationship_params[:primary_record_type],
            related_record_id: relationship_params[:related_record_id],
            related_record_type: relationship_params[:related_record_type]
          )

          record = record_to_update(relationship)
          next if record.nil? || cache.include?(record)

          cache << record

          service = Iiif::Manifest.new
          service.reset_manifests_by_type(record.class, {
            id: record.id,
            project_model_relationship_id: relationship.project_model_relationship_id
          })
        end
      end
    end
  end
end