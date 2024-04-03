require 'typhoeus'

module CoreDataConnector
  class Item < ApplicationRecord
    # Includes
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
  end
end
