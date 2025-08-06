require 'typesense'

module Typesense
  class Base
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
      client.collections.create(schema)
    end

    def index(options)
      # Implemented in sub-class
    end

    def delete
      client.collections[collection_name].delete
    end

    def update
      # Implemented in sub-class
    end

    protected

    def schema
      # Implemented in sub-class
    end
  end
end
