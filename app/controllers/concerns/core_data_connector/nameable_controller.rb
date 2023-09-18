module CoreDataConnector
  module NameableController
    extend ActiveSupport::Concern

    included do
      # Left joins
      left_joins :primary_name

      # Preloads
      preloads :primary_name

      def resolve_search_attribute(attr)
        name_class = "#{item_class.to_s}Name".classify.constantize
        return super unless name_class.column_names.include?(attr.to_s)

        "#{name_class.table_name}.#{attr.to_s}"
      end
    end
  end
end