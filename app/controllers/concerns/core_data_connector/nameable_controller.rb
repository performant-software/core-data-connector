module CoreDataConnector
  module NameableController
    extend ActiveSupport::Concern

    included do
      # Search attributes
      search_attributes :primary_name

      # Left joins
      left_joins :primary_name

      # Preloads
      preloads :primary_name

      def resolve_search_attribute(attr)
        return super unless attr == :primary_name

        name_class = "#{item_class.to_s}Name".classify.constantize
        "#{name_class.table_name}.name"
      end
    end
  end
end