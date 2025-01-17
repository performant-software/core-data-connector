require 'keycloak'

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

    initializer :triple_eye_effable do
      TripleEyeEffable.configure do |config|
        config.api_key = ENV['IIIF_CLOUD_API_KEY']
        config.url = ENV['IIIF_CLOUD_URL']
        config.project_id = ENV['IIIF_CLOUD_PROJECT_ID']
      end
    end

    initializer :keycloak do
      # If true, then all request exception will explode in application (this is the default value)
      Keycloak.generate_request_exception = true
      # controller that manage the user session
      Keycloak.keycloak_controller = 'session'
      # realm name (only if the installation file is not present)
      Keycloak.realm = ENV['KEYCLOAK_REALM_ID']
      # realm url (only if the installation file is not present)
      Keycloak.auth_server_url = ENV['KEYCLOAK_SERVER_URL']
      # The introspect of the token will be executed every time the Keycloak::Client.has_role? method is invoked, if this setting is set to true.
      Keycloak.validate_token_when_call_has_role = false
      # secret (only if  the installation file is not present)
      Keycloak.secret = ENV['KEYCLOAK_SECRET']
      # resource (client_id, only if the installation file is not present)
      Keycloak.resource = ENV['KEYCLOAK_CLIENT_ID']
    end
  end
end
