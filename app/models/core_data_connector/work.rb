module CoreDataConnector
  class Work < ApplicationRecord
    include Identifiable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Work

    name_table :source_titles, polymorphic: true
  end
end
