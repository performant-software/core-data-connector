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
          name: 'coordinates',
          type: 'geopoint',
          facet: false,
          optional: true
        }, {
          name: 'related_instances.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_items.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_media_contents.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_organizations.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_people.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_places.*',
          type: 'auto',
          facet: true
        }, {
          name: 'related_works.*',
          type: 'auto',
          facet: true
        }, {
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
      collection = client.collections[collection_name]

      # Query project_models and build a hash of class names to arrays if project_model IDs
      model_classes = CoreDataConnector::ProjectModel
                        .where(id: project_model_ids)
                        .pluck(:id, :model_class)
                        .inject({}) do |hash, record|
                          id, model_class = record

                          hash[model_class] ||= []
                          hash[model_class] << id

                          hash
                        end

      # Iterate over the keys and query the records belonging to each project model
      model_classes.keys.each do |model_class|
        klass = model_class.constantize
        ids = model_classes[model_class]

        klass.for_search(ids) do |records|
          documents = records.map { |r| r.to_search_json(false) }
          collection.documents.import(documents, action: 'upsert')
        end
      end
    end
  end
end
