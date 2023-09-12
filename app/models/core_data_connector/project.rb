module CoreDataConnector
  class Project < ApplicationRecord
    # Relationships
    has_many :project_models, dependent: :destroy
    has_many :user_projects, dependent: :destroy
  end
end