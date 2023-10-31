module CoreDataConnector
  class RelationshipsSerializer < BaseSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :primary_record_id, :primary_record_type, :related_record_id, :related_record_type,
                     primary_record: FactorySerializer, related_record: FactorySerializer
    show_attributes :id, :primary_record_id, :primary_record_type, :related_record_id, :related_record_type,
                    primary_record: FactorySerializer, related_record: FactorySerializer
  end
end