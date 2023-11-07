require 'rgeo/geo_json'

module CoreDataConnector
  class Geometry
    def self.to_geojson(geometry)
      RGeo::GeoJSON.encode(geometry)
    end

    def self.to_postgis(geometry)
      decoded = RGeo::GeoJSON.decode(geometry)
      return decoded unless decoded.is_a?(RGeo::GeoJSON::FeatureCollection)

      factory = RGeo::Geographic.spherical_factory(srid: 4326, buffer_resolution: 8)
      factory.collection(decoded.instance_variable_get('@features').map(&:geometry))
    end
  end
end