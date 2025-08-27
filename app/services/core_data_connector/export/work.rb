module CoreDataConnector
  module Export
    module Work
      extend ActiveSupport::Concern

      class_methods do
        def export_preloads
          [:ordered_names]
        end
      end

      included do
        # Includes
        include Base

        # Export attributes
        export_attribute :project_model_id
        export_attribute :uuid
        export_attribute(:name) { format_name }
      end
    end
  end
end