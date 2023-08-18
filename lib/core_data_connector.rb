require "core_data_connector/version"
require "core_data_connector/engine"

module CoreDataConnector
  mattr_accessor :config, default: Configuration.new

  def self.configure(&block)
    block.call self.config
  end
end
