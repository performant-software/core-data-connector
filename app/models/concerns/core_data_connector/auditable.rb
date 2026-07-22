module CoreDataConnector
  module Auditable
    extend ActiveSupport::Concern

    class_methods do
      def track_changes(root: nil, **options)
        has_paper_trail(
          versions: { class_name: 'CoreDataConnector::Version' },
          meta: {
            root_type: ->(record) { record.audit_root&.class&.name },
            root_id: ->(record) { record.audit_root&.id },
            root_display_name: ->(record) { record.audit_root&.display_name },
            root_uuid: ->(record) { record.audit_root&.uuid },
            root_project_model_id: ->(record) { record.audit_root&.project_model_id },
            project_id: ->(record) { record.audit_root&.project_id },
            meta: ->(record) { record.audit_metadata }
          },
          **options,
          ignore: [
            :id,
            :created_at,
            :updated_at,
            :uuid,
            :import_id,
            :project_model_id,
            :z_event_id,
            :z_instance_id,
            :z_item_id,
            :z_media_content_id,
            :z_organization_id,
            :z_person_id,
            :z_place_id,
            :z_taxonomy_id,
            :z_work_id
          ].concat(options[:ignore] || []),
        )

        if root
          define_method(:audit_root) { root.call(self) }
        else
          define_method(:audit_root) { self }
        end
      end
    end

    # Additional model-specific data to store alongside each version
    def audit_metadata
      nil
    end
  end
end
