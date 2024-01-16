module CoreDataConnector
  class Instance < ApplicationRecord
    include Identifiable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Instance

    name_table :source_titles, polymorphic: true
  end
end
