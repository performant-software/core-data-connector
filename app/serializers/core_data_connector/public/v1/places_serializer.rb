module CoreDataConnector
  module Public
    module V1
      class PlacesSerializer < PublicSerializer
        include TypeableSerializer
        include UserDefineableSerializer

        context 'https://raw.githubusercontent.com/LinkedPasts/linked-places/master/linkedplaces-context-v1.1.jsonld',
                id: '@id', name: 'lpo:name_attestation', place_names: { name: 'lpo:name_attestation' },
                place_geometry: { geometry_json: 'geojson-t:geometry' }, web_identifiers: { identifier: 'lpo:link_attestation' }

        index_attributes :uuid, :name, place_geometry: PlaceGeometriesSerializer
        show_attributes :uuid, :name, place_names: [:name, :primary], place_geometry: PlaceGeometriesSerializer,
                        web_identifiers: WebIdentifiersSerializer
      end
    end
  end
end
