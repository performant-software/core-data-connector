module CoreDataConnector
  class RelationshipsSerializer < BaseSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :related_record_id, :related_record_type, related_record: FactorySerializer
    show_attributes :id, :related_record_id, :related_record_type, related_record: FactorySerializer
  end
end