module CoreDataConnector
  class Person < ApplicationRecord
    # Includes
    include DisplayNameable
    include Export::Person
    include Identifiable
    include ImportAnalyze::Person
    include Manifestable
    include Mergeable
    include Nameable
    include Ownable
    include Reconcile::Person
    include Relateable
    include Search::Person
    include UserDefinedFields::Fieldable

    # Delegates
    delegate :first_name, :middle_name, :last_name, to: :primary_name, allow_nil: true

    # Nameable table
    name_table :person_names

    def self.name_column
      "CONCAT_WS(' ', first_name, middle_name, last_name)"
    end

    # User defined fields parent
    resolve_defineable -> (person) { person.project_model }

    def full_name
      [first_name, middle_name, last_name].compact.join(' ')
    end

    def display_name
      full_name
    end
  end
end
