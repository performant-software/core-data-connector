module CoreDataConnector
  module Public
    class PlacesSerializer < BaseSerializer
      include TypeableSerializer
      include UserDefineableSerializer

      index_attributes :uuid, :name, place_geometry: PlaceGeometriesSerializer
      show_attributes :uuid, :name, place_names: [:id, :name, :primary], place_geometry: PlaceGeometriesSerializer
    end
  end
end
