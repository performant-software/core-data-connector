module CoreDataConnector
  class ProjectModel < ApplicationRecord
    # Includes
    include UserDefinedFields::Defineable

    # Relationships
    belongs_to :project

    # Validations
    validates :name, presence: true
    validates :model_class, inclusion: { in: :valid_model_classes }

    # Returns a list of models that include the Ownable concern.
    def self.model_classes
      # Eager load all of the models in development mode
      Rails.application.eager_load! if Rails.env.development?

      # Return the list of values
      ApplicationRecord.descendants.select do |descendant|
        descendant.included_modules&.include?(Ownable) && descendant.model_name.present?
      end
    end

    # Returns a human readable model class name.
    def model_class_view
      model_class&.safe_constantize&.model_name&.human
    end

    private

    # Returns a list of valid model class names.
    def valid_model_classes
      self.class.model_classes.map(&:model_name).map(&:name)
    end
  end
end