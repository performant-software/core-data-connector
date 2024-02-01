module CoreDataConnector
  class PlacesSerializer < BaseSerializer
    include OwnableSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :name
    show_attributes :id, :name, place_names: [:id, :name, :primary], place_geometry: PlaceGeometriesSerializer,
                    place_layers: PlaceLayersSerializer
  end
end
