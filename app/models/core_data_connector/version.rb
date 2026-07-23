module CoreDataConnector
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    self.table_name = 'core_data_connector_versions'

    # Relationships
    has_one :user, foreign_key: :id, primary_key: :whodunnit

    def self.for_record(record)
      where('roots @> ?', [{ type: record.class.name, id: record.id }].to_json)
    end

    # Group by request_uuid so we can combine changes to multiple tables that were semantically
    # part of the same record action. (e.g. place name + geometry)
    def self.changesets
      order(created_at: :desc, id: :desc)
        .group_by { |version| version.request_uuid }
    end
  end
end
