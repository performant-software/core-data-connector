module CoreDataConnector
  module RelatedColumnable
    extend ActiveSupport::Concern
    def index
      query = base_query
      query = build_query(query)
      query = apply_search(query)
      query = apply_filters(query)
      query = apply_sort(query)

      list, items = pagy(query, items: per_page, page: params[:page])
      metadata = pagy_metadata(list)

      items = hydrate_related_columns(items)
      preloads(items)

      render json: build_index_response(items, metadata), status: :ok
    end

    protected

    def hydrate_related_columns(items)
      cols = permitted_related_columns
      return items if cols.empty? || items.empty?

      ids = items.map(&:id)
      rehydrated = CoreDataConnector::RecordTableQuery.new(
        source_model:    item_class,
        related_columns: cols
      ).call(item_class.where(id: ids)).index_by(&:id)

      # Preserve the order pagy gave us (which respects apply_sort)
      ids.map { |id| rehydrated[id] }.compact
    end

    def permitted_related_columns
      @permitted_related_columns ||= begin
                                       raw = params[:join_columns]

                                       base_columns = Array(raw).map do |c|
                                         split = c.split('_')
                                         next unless split.length == 3

                                         { pmr_id: split[1].to_i, field: split[2] }
                                       end

                                       base_columns.map { |c| c.respond_to?(:permit) ? c.permit(:pmr_id, :field) : c }
                                                   .map { |c| { pmr_id: c[:pmr_id], field: c[:field].to_s } }
                                                   .reject { |c| c[:pmr_id].zero? || c[:field].empty? }
                                     end
    end

    def related_column_aliases
      permitted_related_columns.map do |c|
        "rel_#{c[:pmr_id]}_#{c[:field].gsub(/\W/, '_')}"
      end
    end

    def load_records(items)
      super.merge(related_column_aliases: related_column_aliases)
    end
  end
end