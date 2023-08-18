module CoreDataConnector
  class Location < ApplicationRecord
    self.primary_key = :id

    # Relationships
    belongs_to :place
    belongs_to :locateable, polymorphic: true
  end
end
