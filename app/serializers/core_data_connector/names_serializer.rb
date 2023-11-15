module CoreDataConnector
  class NamesSerializer < BaseSerializer
    index_attributes :id, :name
    show_attributes :id, :name
  end
end
