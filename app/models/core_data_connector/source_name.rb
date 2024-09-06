module CoreDataConnector
  class SourceName < ApplicationRecord
    belongs_to :nameable, polymorphic: true
  end
end
