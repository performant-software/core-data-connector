module CoreDataConnector
  class Organization < ApplicationRecord
    # Includes
    include Nameable
    include Ownable

    # Delegates
    delegate :name, to: :primary_name
  end
end