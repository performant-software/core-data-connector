module CoreDataConnector
  class Person < ApplicationRecord
    # Includes
    include Nameable
    include Ownable
    include Relateable
    include Search::Person
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :first_name, :middle_name, :last_name, to: :primary_name

    name_table :person_names

    # User defined fields parent
    resolve_defineable -> (person) { person.project_model }

    def full_name
      [first_name, middle_name, last_name].compact.join(' ')
    end
  end
end
