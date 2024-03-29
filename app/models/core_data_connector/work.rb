module CoreDataConnector
  class Work < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Work

    # Nameable table
    name_table :source_titles, polymorphic: true
  end
end
