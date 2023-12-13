module CoreDataConnector
  module Nameable
    extend ActiveSupport::Concern

    class_methods do
      def name_table(name, options = nil)
        if options && options[:polymorphic]
          self.send(:has_many, name.to_sym, as: :nameable, dependent: :destroy)
          has_one :primary_name, -> { where(primary: true) }, class_name: name.to_s.classify, as: :nameable
        else
          self.send(:has_many, name.to_sym, dependent: :destroy)
          has_one :primary_name, -> { where(primary: true) }, class_name: name.to_s.classify
        end

        # Nested attributes
        self.send(:accepts_nested_attributes_for, name.to_sym, allow_destroy: true)

        @names_table = name
      end

      def get_names_table
        @names_table
      end
    end

    included do
      # Validations
      validate :validate_names

      private

      def has_primary_name?
        names = self.send(self.class.get_names_table)
        names.select{ |n| n.primary? }.present?
      end

      def validate_names
        errors.add(:names, I18n.t('errors.nameable.primary_name')) unless has_primary_name?
      end
    end
  end
end