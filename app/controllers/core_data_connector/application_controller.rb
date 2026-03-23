module CoreDataConnector
  class ApplicationController < Api::ResourceController
    # Includes
    include JwtAuth::Authenticateable
    include ClerkAuthenticatable

    # Actions
    skip_before_action :authenticate_request
    before_action :handle_authentication

    def item_class
      "CoreDataConnector::#{controller_name.singularize.classify}".constantize
    end

    def serializer_class
      "CoreDataConnector::#{"#{controller_name}_serializer".classify}".constantize
    end

    private

    def handle_authentication
      if is_clerk?
        authenticate_clerk_request
      else
        authenticate_request
      end
    end

    def log_error(error)
      Rails.logger.error (["#{self.class} - #{error.class}: #{error.message}", error.backtrace]).join("\n")
    end
  end
end
