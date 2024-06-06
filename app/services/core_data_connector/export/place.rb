module CoreDataConnector
  module Export
    module Place
      extend ActiveSupport::Concern

      class_methods do
        def export_query
          self.all.with_centroid
        end

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
        export_attribute :name

        export_attribute(:latitude) do
          geometry_center&.y
        end

        export_attribute(:longitude) do
          geometry_center&.x
        end
      end
    end
  end
end