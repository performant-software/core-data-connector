module CoreDataConnector
  module Reconcile
    class Manager

      def send_request(queries, credentials)
        client = Typesense.create_client(**credentials.except(:collection_name))

        common_params = {
          query_by: 'name'
        }

        params = build_params(queries, credentials[:collection_name])
        response = client.multi_search.perform(params, common_params)

        transform response, queries.keys
      end

      private

      def build_params(queries, collection)
        searches = []

        queries.keys.each do |key|
          query = queries[key]

          # Append "collection" and "query" parameters
          search = { collection:, q: query[:query] }

          # Append "filter_by" parameter, if present
          search[:filter_by] = "type:#{query[:type]}" if query[:type].present?

          # Append "limit" parameter, if present
          search[:limit] = query[:limit] if query[:limit].present?

          searches << search
        end

        { searches: }
      end

      def transform(response, keys)
        json = {}

        response['results'].each_with_index do |result, index|
          json[keys[index]] = transform_results(result['hits'])
        end

        json
      end

      def transform_result(result)
        klass = result['document']['type'].constantize

        attributes = {
          score: result['text_match'],
          match: false,
          type: {
            id: klass.to_s,
            name: klass.name.demodulize
          }
        }

        all_attributes = result['document'].merge(attributes).symbolize_keys
        transformed = ActiveSupport::InheritableOptions.new(all_attributes)

        # For some reason, adding "present" to the constructor does not work
        transformed.present = true

        transformed
      end

      def transform_results(results)
        results.map { |result| transform_result(result) }
      end

    end
  end
end