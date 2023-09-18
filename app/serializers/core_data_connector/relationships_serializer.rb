module CoreDataConnector
  class RelationshipsSerializer < BaseSerializer
    index_attributes :id, :related_record_id, :related_record_type, related_record: FactorySerializer
    show_attributes :id, :related_record_id, :related_record_type, related_record: FactorySerializer
  end
end