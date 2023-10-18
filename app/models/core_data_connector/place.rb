module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Includes
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :name, to: :primary_name

    # User defined fields parent
    resolve_defineable -> (place) { place.project_model }
  end
end
