module CoreDataConnector
  class MediaContent < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Mergeable
    include Ownable
    include Relateable
    include Search::MediaContent
    include TripleEyeEffable::Resourceable
    include UserDefinedFields::Fieldable

    after_save :update_manifests

    def update_manifests
      iiif_service = Iiif::Manifest.new

      self.relationships.each { |r| update_relationship_manifests(r, iiif_service, true) }
      self.related_relationships.each { |r| update_relationship_manifests(r, iiif_service, false) }
    end

    def update_relationship_manifests(relationship, service, is_primary)
      if is_primary
        model_class = relationship.related_record_type.constantize
        related_record_id = relationship.related_record_id
      else
        model_class = relationship.primary_record_type.constantize
        related_record_id = relationship.primary_record_id
      end

      service.reset_manifests_by_type(model_class, {
        id: related_record_id,
        project_model_relationship_id: relationship.project_model_relationship_id,
        limit: ENV['IIIF_MANIFEST_ITEM_LIMIT']
      })
    end

    def metadata
      if !self.user_defined || self.user_defined.keys.count == 0
        return '[]'
      end

      fields = UserDefinedFields::UserDefinedField.where(uuid: self.user_defined.keys).map do |udf|
        {
          label: udf[:column_name],
          value: self.user_defined[udf[:uuid]]
        }
      end

      fields.to_json
    end

    # User defined fields parent
    resolve_defineable -> (media_content) { media_content.project_model }
  end
end