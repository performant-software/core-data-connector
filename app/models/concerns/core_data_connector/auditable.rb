module CoreDataConnector
  module Auditable
    extend ActiveSupport::Concern

    class_methods do
      def track_changes(root: nil, **options)
        has_paper_trail(
          versions: { class_name: 'CoreDataConnector::Version' },
          ignore: [:updated_at],
          meta: {
            root_type: ->(record) { record.audit_root&.class&.name },
            root_id: ->(record) { record.audit_root&.id },
            meta: ->(record) { record.audit_metadata }
          },
          **options
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
