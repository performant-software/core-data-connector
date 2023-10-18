module CoreDataConnector
  class Engine < ::Rails::Engine
    isolate_namespace CoreDataConnector
    config.generators.api_only = true

    initializer :core_data_connector do
      TripleEyeEffable.configure do |config|
        config.api_key = ENV['IIIF_CLOUD_API_KEY']
        config.url = ENV['IIIF_CLOUD_URL']
        config.project_id = ENV['IIIF_CLOUD_PROJECT_ID']
      end
    end
  end
end
