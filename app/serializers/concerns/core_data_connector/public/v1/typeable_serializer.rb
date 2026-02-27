module CoreDataConnector
  module Public
    module V1
      module TypeableSerializer
        extend ActiveSupport::Concern

        included do
          index_attributes(:project_model_relationship_uuid) { |item| relationship_uuid(item).length > 1 ? relationship_uuid(item) : relationship_uuid(item)[0] }
          index_attributes(:project_model_relationship_inverse) { |item| relationship_inverse(item) }

          protected

          def self.relationship_inverse(item)
            !item.relationships.empty?
          end

          def self.relationship_uuid(item)
            if !item.relationships.empty?
              item.relationships.map{ |r| r.project_model_relationship.uuid }.uniq
            elsif !item.related_relationships.empty?
              item.related_relationships.map { |r| r.project_model_relationship.uuid }.uniq
            end
          end
        end
      end
    end
  end
end