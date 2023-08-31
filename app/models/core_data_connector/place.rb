module CoreDataConnector
  class Place < ApplicationRecord
    self.primary_key = :id

    # Relationships
    has_many :place_names, dependent: :destroy
    has_one :primary_name, -> { where(primary: true) }, class_name: 'PlaceName'

    # Nested attributes
    accepts_nested_attributes_for :place_names, allow_destroy: true

    # Resourceable parameters
    allow_params place_names_attributes: [:id, :name, :primary, :_destroy]

    # Validations
    validate :validate_place_names

    def name
      primary_name&.name
    end

    private

    def has_primary_name?
      place_names.select{ |pn| pn.primary? }.present?
    end

    def validate_place_names
      errors.add(:place_names, I18n.t('errors.place.primary_name')) unless has_primary_name?
    end
  end
end
