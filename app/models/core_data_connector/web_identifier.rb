module CoreDataConnector
  class WebIdentifier < ApplicationRecord
    # Relationships
    belongs_to :identifiable, polymorphic: true
    belongs_to :web_authority
  end
end