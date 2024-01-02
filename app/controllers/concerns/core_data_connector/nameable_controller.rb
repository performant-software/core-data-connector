module CoreDataConnector
  module NameableController
    extend ActiveSupport::Concern

    included do
      # Left joins
      left_joins :primary_name

      # Preloads
      preloads :primary_name

      search_methods :search_by_name

      def resolve_search_attribute(attr)
        name_class = "CoreDataConnector::#{item_class.get_names_table.to_s.classify}".constantize

        return super unless name_class.column_names.include?(attr.to_s)

        "#{name_class.table_name}.#{attr.to_s}"
      end

      def search_by_name(query)
        return query if params[:search].blank?

        name_class = "CoreDataConnector::#{item_class.get_names_table.to_s.classify}".constantize
        
        is_polymorphic = !!name_class.reflect_on_all_associations(:belongs_to).find { |a| a.name == :name}

        return query if !is_polymorphic

        or_query = item_class
          .where(
            Name
              .joins(item_class.get_names_table)
              .where(name_class.arel_table[:primary].eq(true))
              .where(name_class.arel_table[:nameable_id].eq(item_class.arel_table[:id]))
              .where(name_class.arel_table[:nameable_type].eq(item_class.to_s))
              .where('core_data_connector_names.name ILIKE ?', "%#{params[:search]}%")
              .arel.exists
            )

        if query == item_class.all
          query.merge(or_query)
        else
          query.or(or_query)
        end
      end
    end
  end
end
