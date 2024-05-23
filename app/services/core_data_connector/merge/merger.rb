module CoreDataConnector
  module Merge
    class Merger
      MANIFEST_ATTRIBUTES = [
        :project_model_relationship_id
      ]

      RELATIONSHIP_ATTRIBUTES = [
        :project_model_relationship_id,
        :primary_record_type,
        :related_record_id,
        :related_record_type,
        :user_defined
      ]

      RELATED_RELATIONSHIP_ATTRIBUTES = [
        :project_model_relationship_id,
        :primary_record_id,
        :primary_record_type,
        :related_record_type,
        :user_defined
      ]

      WEB_IDENTIFIER_ATTRIBUTES = [
        :web_authority_id,
        :identifier,
        :extra
      ]

      def merge(new_record, merged_records)
        manifests = []
        relationships = []
        related_relationships = []
        web_identifiers = []

        merged_records.each do |record|
          # Append the manifests from the merged record(s) to the new record
          record.manifests.each { |manifest| add_item(manifests, manifest, MANIFEST_ATTRIBUTES) }

          # Append the relationships from the merged record(s) to the new record
          record.relationships.each { |relationship| add_item(relationships, relationship, RELATIONSHIP_ATTRIBUTES) }
          record.related_relationships.each { |relationship| add_item(related_relationships, relationship, RELATED_RELATIONSHIP_ATTRIBUTES) }

          # Append the web identifiers from the merged record(s) to the new record
          record.web_identifiers.each { |web_identifier| add_item(web_identifiers, web_identifier, WEB_IDENTIFIER_ATTRIBUTES) }
        end

        # Add the manifests to the new record
        manifests.each { |manifest| manifest.manifestable = new_record }
        new_record.manifests = manifests

        # Add the relationships to the new record
        relationships.each { |relationship| relationship.primary_record = new_record }
        new_record.relationships = relationships

        related_relationships.each { |relationship| relationship.related_record = new_record }
        new_record.related_relationships = related_relationships

        # Add web identifiers to the new record
        web_identifiers.each { |web_identifier| web_identifier.identifiable = new_record }
        new_record.web_identifiers = web_identifiers

        # Save the new record
        success = new_record.save

        if success
          # Re-generate manifests
          service = Iiif::Manifest.new
          service.reset_manifests_by_type(new_record.class, { id: new_record.id })

          # Destroy the merged records
          merged_records.destroy_all
        end
      end

      private

      def add_item(array, item, attrs)
        included = false

        array.each do |i|
          included = true and break if attrs.all? { |attr| i[attr] == item[attr] }
        end

        array << item.dup unless included
      end
    end
  end
end