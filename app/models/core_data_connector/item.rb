module CoreDataConnector
  class Item < ApplicationRecord
    # Includes
    include Export::Item
    include FccImportable
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Item

    # Nameable table
    name_table :source_titles, polymorphic: true

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end
