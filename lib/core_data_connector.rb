require 'core_data_connector/version'
require 'core_data_connector/engine'
require 'core_data_connector/configuration'

module CoreDataConnector
  mattr_accessor :config, default: Configuration.new

  def self.configure(&block)
    block.call self.config
  end
end
