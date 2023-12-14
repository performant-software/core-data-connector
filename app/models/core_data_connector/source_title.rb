module CoreDataConnector
  class SourceTitle < ApplicationRecord
    belongs_to :name
    belongs_to :nameable, polymorphic: true

    belongs_to :instance, foreign_key: :nameable_id, optional: true
    belongs_to :item, foreign_key: :nameable_id, optional: true
    belongs_to :work, foreign_key: :nameable_id, optional: true

    accepts_nested_attributes_for :name
  end
end
