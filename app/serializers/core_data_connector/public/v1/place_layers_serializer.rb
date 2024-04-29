module CoreDataConnector
  module Public
    module V1
      class PlaceLayersSerializer < BaseSerializer
        index_attributes :id, :name, :layer_type, :geometry, :url
        show_attributes :id, :name, :layer_type, :geometry, :url
      end
    end
  end
end