module CoreDataConnector
  class SourceName < ApplicationRecord
    # Includes
    include Auditable

    # Audit logging
    track_changes root: ->(source_name) { source_name.nameable }

    # Relationships
    belongs_to :nameable, polymorphic: true
  end
end
