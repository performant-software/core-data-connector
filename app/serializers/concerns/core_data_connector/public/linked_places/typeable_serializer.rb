module CoreDataConnector
  module Public
    module LinkedPlaces
      module TypeableSerializer
        extend ActiveSupport::Concern

        included do
          include ::CoreDataConnector::Public::TypeableSerializer

          annotation_attributes(:relationship_type) { |item, current_user, options| relationship_type(item, options) }
        end
      end
    end
  end
end