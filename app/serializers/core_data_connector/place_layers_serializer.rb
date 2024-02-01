module CoreDataConnector
  class PlaceLayersSerializer < BaseSerializer
    index_attributes :id, :name, :layer_type, :geometry, :url
    show_attributes :id, :name, :layer_type, :geometry, :url
  end
end