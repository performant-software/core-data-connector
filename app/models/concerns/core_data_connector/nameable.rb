module CoreDataConnector
  module Nameable
    extend ActiveSupport::Concern

    included do
      has_many "#{self.model_name.param_key}_names".to_sym, dependent: :destroy
      has_one :primary_name, -> { where(primary: true) }, class_name: "#{self.name}Name"

      # Nested attributes
      accepts_nested_attributes_for "#{self.model_name.param_key}_names".to_sym, allow_destroy: true

      # Validations
      validate :validate_names

      private

      def has_primary_name?
        names = self.send("#{self.class.model_name.param_key}_names".to_sym)
        names.select{ |n| n.primary? }.present?
      end

      def validate_names
        errors.add(:names, I18n.t('errors.nameable.primary_name')) unless has_primary_name?
      end
    end
  end
end