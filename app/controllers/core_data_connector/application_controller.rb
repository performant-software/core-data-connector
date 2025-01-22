module CoreDataConnector
  class ApplicationController < Api::ResourceController
    # Includes
    include JwtAuth::Authenticateable

    def item_class
      "CoreDataConnector::#{controller_name.singularize.classify}".constantize
    end

    def serializer_class
      "CoreDataConnector::#{"#{controller_name}_serializer".classify}".constantize
    end

    protected

    def log_error(error)
      Rails.logger.error (["#{self.class} - #{error.class}: #{error.message}", error.backtrace]).join("\n")
    end
  end
end
