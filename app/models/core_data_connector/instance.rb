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
  end
end
