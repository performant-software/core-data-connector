module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Includes
    include Nameable
    include Ownable
    include Relateable

    # Relationships
    belongs_to :project_model

    # Delegates
    delegate :name, to: :primary_name
  end
end
