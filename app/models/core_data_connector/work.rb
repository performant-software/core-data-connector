module CoreDataConnector
  class Work < ApplicationRecord
    # Includes
    include Export::Work
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Work

    # Nameable table
    name_table :source_titles, polymorphic: true

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end
