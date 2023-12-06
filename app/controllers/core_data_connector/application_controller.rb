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
  end
end
