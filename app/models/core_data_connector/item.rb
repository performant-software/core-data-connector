module CoreDataConnector
  class Item < ApplicationRecord
    include Identifiable
    include Nameable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Item

    name_table :source_titles, polymorphic: true
  end
end
