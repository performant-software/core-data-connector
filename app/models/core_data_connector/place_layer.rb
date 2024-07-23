module CoreDataConnector
  class PlaceLayer < ApplicationRecord
    LAYER_TYPES = %w(geojson raster georeference)

    # Relationships
    belongs_to :place

    # Validations
    validates :name, presence: true
    validates :layer_type, inclusion: { in: LAYER_TYPES }
    validates :content, presence: true, if: -> { url.blank? }
    validates :url, presence: true, if: -> { content.blank? }
  end
end