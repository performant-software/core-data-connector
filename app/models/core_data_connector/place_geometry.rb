module CoreDataConnector
  class PlaceGeometry < ApplicationRecord
    # Includes
    include Auditable

    # todo: we can't directly log geometry updates, but we
    # should store some sort of event in Papertrail.

    # Relationships
    belongs_to :place

    # Transient attributes
    attr_accessor :geometry_json

    # Callbacks
    before_save :set_geometry

    # Stores a GeoJSON snapshot of the geometry on each version.
    def audit_metadata
      return nil if geometry.blank?

      { geometry: to_geojson }
    end

    # Returns the "geometry" as GeoJSON
    def to_geojson
      Geometry.to_geojson(self.geometry)
    end

    private

    # Sets the geometry attribute if the geometry_json attribute is provided.
    def set_geometry
      return unless self.geometry_json.present?

      json = JSON.parse(self.geometry_json)
      self.geometry = Geometry.to_postgis(json)
    end
  end
end