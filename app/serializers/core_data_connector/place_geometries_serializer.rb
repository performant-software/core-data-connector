module CoreDataConnector
  class PlaceGeometriesSerializer < BaseSerializer
    index_attributes :id, geometry_json: -> (pm, *rest) { pm.to_geojson }
    show_attributes :id, geometry_json: -> (pm, *rest) { pm.to_geojson }
  end
end