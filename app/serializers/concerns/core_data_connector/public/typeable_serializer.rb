module CoreDataConnector
  module Public
    module TypeableSerializer
      extend ActiveSupport::Concern

      included do
        index_attributes(:relationship_type) do |item, current_user, options|
          if options[:nested_resource].to_s.to_bool
            if !item.relationships.empty?
              item.relationships.map{ |r| r.project_model_relationship.inverse_name }.first
            elsif !item.related_relationships.empty?
              item.related_relationships.map { |r| r.project_model_relationship.name }.first
            end
          end
        end
      end
    end
  end
end