module CoreDataConnector
  module Public
    class PlaceGeometriesSerializer < BaseSerializer
      index_attributes geometry_json: -> (pg, *rest) { pg.to_geojson }
      show_attributes geometry_json: -> (pg, *rest) { pg.to_geojson }
    end
  end
end