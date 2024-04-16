module CoreDataConnector
  class EventsSerializer < BaseSerializer
    include OwnableSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :name, :description
    show_attributes :id, :name, :description
  end
end