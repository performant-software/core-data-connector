module CoreDataConnector
  class ApplicationController < CoreDataConnector.config.base_controller_class.constantize
    def current_user
      return super if defined?(super)

      nil
    end

    def item_class
      "CoreDataConnector::#{controller_name.singularize.classify}".constantize
    end

    def serializer_class
      "CoreDataConnector::#{"#{controller_name}_serializer".classify}".constantize
    end
  end
end
