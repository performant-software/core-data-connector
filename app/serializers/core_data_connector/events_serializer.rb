module CoreDataConnector
  class EventsSerializer < BaseSerializer
    include OwnableSerializer

    index_attributes :id, :name, :description
    show_attributes :id, :name, :description
  end
end