module CoreDataConnector
  class WebIdentifier < ApplicationRecord
    # Includes
    include Export::WebIdentifier

    # Relationships
    belongs_to :identifiable, polymorphic: true
    belongs_to :web_authority

    # Callbacks
    before_create :find_identifier

    def self.all_records_by_project(project_id)
      WebIdentifier
        .joins(:web_authority)
        .where(web_authority: { project_id: project_id })
    end

    private

    def find_identifier
      service = Authority::Base.create_service(web_authority)
      service.before_create(self)
    end
  end
end