module CoreDataConnector
  class Name < ApplicationRecord
    has_many :source_titles
  end
end
