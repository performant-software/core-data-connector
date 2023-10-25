module CoreDataConnector
  class Person < ApplicationRecord
    # Includes
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :first_name, :middle_name, :last_name, to: :primary_name

    # User defined fields parent
    resolve_defineable -> (person) { person.project_model }
  end
end
