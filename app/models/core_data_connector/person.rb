module CoreDataConnector
  class Person < ApplicationRecord
    # Includes
    include Nameable
    include Ownable

    # Relationships
    belongs_to :project_model

    # Delegates
    delegate :first_name, :middle_name, :last_name, to: :primary_name
  end
end
