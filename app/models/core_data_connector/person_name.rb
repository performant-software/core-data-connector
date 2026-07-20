module CoreDataConnector
  class PersonName < ApplicationRecord
    # Includes
    include Auditable

    # Audit logging
    track_changes root: ->(person_name) { person_name.person }

    # Relationships
    belongs_to :person
  end
end
