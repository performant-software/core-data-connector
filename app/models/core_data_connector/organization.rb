module CoreDataConnector
  class Organization < ApplicationRecord
    # Includes
    include Nameable
    include Ownable

    # Relationships
    belongs_to :project_model

    # Delegates
    delegate :name, to: :primary_name
  end
end