module CoreDataConnector
  class Instance < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Instance

    # Nameable table
    name_table :source_titles, polymorphic: true

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end
