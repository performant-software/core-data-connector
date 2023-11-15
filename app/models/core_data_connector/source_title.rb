module CoreDataConnector
  class SourceTitle < ApplicationRecord
    belongs_to :name
    belongs_to :nameable, polymorphic: true

    accepts_nested_attributes_for :name
  end
end
