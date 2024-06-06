module CoreDataConnector
  module Export
    module Work
      extend ActiveSupport::Concern

      class_methods do
        def export_preloads
          [:primary_name]
        end
      end

      included do
        # Includes
        include Base

        # Export attributes
        export_attribute :project_model_id
        export_attribute :uuid

        export_attribute(:name) do
          primary_name&.name&.name
        end
      end
    end
  end
end