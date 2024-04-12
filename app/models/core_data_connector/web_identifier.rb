module CoreDataConnector
  class WebIdentifier < ApplicationRecord
    # Relationships
    belongs_to :identifiable, polymorphic: true
    belongs_to :web_authority

    # Callbacks
    before_create :find_identifier

    private

    def find_identifier
      service = Authority::Base.create_service(web_authority)
      service.before_create(self)
    end
  end
end