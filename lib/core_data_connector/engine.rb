module CoreDataConnector
  class Engine < ::Rails::Engine
    isolate_namespace CoreDataConnector
    config.generators.api_only = true

    initializer :rack_cors do |app|
      app.config.app_middleware.insert_before 0, Rack::Cors do
        allow do
          origins '*'
          resource '/core_data/public/*', methods: :get
        end
      end
    end

    initializer :jwt_auth do
      JwtAuth.configure do |config|
        config.model_class = 'CoreDataConnector::User'
        config.login_attribute = 'email'
        config.user_serializer = 'CoreDataConnector::UsersSerializer'
      end
    end

    initializer :core_data_connector do
      TripleEyeEffable.configure do |config|
        config.api_key = ENV['IIIF_CLOUD_API_KEY']
        config.url = ENV['IIIF_CLOUD_URL']
        config.project_id = ENV['IIIF_CLOUD_PROJECT_ID']
      end
    end
  end
end
