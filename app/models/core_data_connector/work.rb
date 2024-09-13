module CoreDataConnector
  class Work < ApplicationRecord
    # Includes
    include Export::Work
    include Identifiable
    include Manifestable
    include Mergeable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Work

    # Nameable table
    name_table :source_names, as: :nameable

    # Delegates
    delegate :name, to: :primary_name, allow_nil: true

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end
