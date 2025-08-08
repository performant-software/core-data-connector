require 'typesense'

module CoreDataConnector
  class Typesense

    def self.create_client(host:, port:, protocol:, api_key:)
      ::Typesense::Client.new(
        nodes: [{
          host: host || 'localhost',
          port: port|| 8108,
          protocol: protocol || 'http'
        }],
        api_key: api_key || 'xyz',
        num_retries: 10,
        healthcheck_interval_seconds: 1,
        retry_interval_seconds: 0.01,
        connection_timeout_seconds: 10,
        logger: Logger.new($stdout),
        log_level: Logger::INFO
      )
    end

  end
end