require 'typesense'

module Typesense
  class Helper
    attr_reader :client, :collection_name

    def initialize(host:, port:, protocol:, api_key:, collection_name:)
      @client = Client.new(
        nodes: [
          {
            host: host || 'localhost',
            port: port|| 8108,
            protocol: protocol || 'http'
          }
        ],
        api_key: api_key || 'xyz',
        num_retries: 10,
        healthcheck_interval_seconds: 1,
        retry_interval_seconds: 0.01,
        connection_timeout_seconds: 10,
        logger: Logger.new($stdout),
        log_level: Logger::INFO
      )

      @collection_name = collection_name
    end

    def create
      schema = {
        name: collection_name,
        enable_nested_fields: true,
        fields: [{
          name: '.*_facet',
          type: 'auto',
          facet: true
        }, {
          name: '.*',
          type: 'auto'
        }]
      }

      client.collections.create(schema)
    end

    def delete
      client.collections[collection_name].delete
    end

    def index(project_model_ids)
      project_models = CoreDataConnector::ProjectModel.where(id: project_model_ids)
      klass = project_models.first.model_class.constantize

      collection = client.collections[collection_name]

      klass.for_search(project_model_ids) do |records|
        documents = records.map { |r| r.to_search_json(false) }
        collection.documents.import(documents, action: 'upsert')
      end
    end
  end
end
