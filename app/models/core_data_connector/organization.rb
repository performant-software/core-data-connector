module CoreDataConnector
  class Organization < ApplicationRecord
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