module CoreDataConnector
  class PlaceGeometry < ApplicationRecord
    # Relationships
    belongs_to :place

    # Transient attributes
    attr_accessor :geometry_json

    # Callbacks
    before_save :set_geometry

    def to_geojson
      Geometry.to_geojson(self.geometry)
    end

    private

    # Sets the geometry attribute if the geometry_json attribute is provided.
    def set_geometry
      return unless self.geometry_json.present?

      self.geometry = Geometry.to_postgis(self.geometry_json)
    end
  end
end