module CoreDataConnector
  class Engine < ::Rails::Engine
    isolate_namespace CoreDataConnector
    config.generators.api_only = true
  end
end
