module CoreDataConnector
  class RecordMergesSerializer < BaseSerializer
    index_attributes :id, :merged_uuid, :created_at
    show_attributes :id, :merged_uuid, :created_at
  end
end