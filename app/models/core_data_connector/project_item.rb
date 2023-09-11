module CoreDataConnector
  class ProjectItem < ApplicationRecord
    belongs_to :project
    belongs_to :ownable, polymorphic: true
  end
end