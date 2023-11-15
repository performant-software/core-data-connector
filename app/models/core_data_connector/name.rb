module CoreDataConnector
  class Name < ApplicationRecord
    has_many :source, through: :source_titles, source: :nameable, source_type: 'Instance'
    has_many :source, through: :source_titles, source: :nameable, source_type: 'Item'
    has_many :source, through: :source_titles, source: :nameable, source_type: 'Work'

    has_many :source_titles
  end
end
