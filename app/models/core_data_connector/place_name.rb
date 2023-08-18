module CoreDataConnector
  class PlaceName < ApplicationRecord
    self.primary_key = :id

    # Relationships
    belongs_to :place
  end
end
