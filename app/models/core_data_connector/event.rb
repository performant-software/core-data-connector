module CoreDataConnector
  class Event < ApplicationRecord
    # Includes
    include Identifiable
    include Ownable
    include Relateable
  end
end