module CoreDataConnector
  class Item < ApplicationRecord
    # Includes
    include Export::Item
    include FccImportable
    include Identifiable
    include ImportAnalyze::Item
    include Manifestable
    include Mergeable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Item

    # Nameable table
    name_table :source_names, as: :nameable

    # Delegates
    delegate :name, to: :primary_name, allow_nil: true

    # User defined fields parent
    resolve_defineable -> (organization) { organization.project_model }
  end
end
