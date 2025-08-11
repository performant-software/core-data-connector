module CoreDataConnector
  module Reconcile
    class ProjectsController < ActionController::API

      def show
        # Validate that the requested project contains the necessary credentials to call the API
        project = Project.find(params[:id])
        credentials = project.reconciliation_credentials&.symbolize_keys

        render json: { }, status: :not_found and return unless valid_credentials? credentials

        serializer = serializer_class.new

        # Per the spec, a request to the API without any parameters should return the service manifest
        render json: serializer.render_manifest, status: :ok and return unless params[:queries].present?

        # Allow request body to be sent as application/json or x-www-form-urlencoded
        if params[:queries].is_a?(String)
          queries = JSON.parse(params[:queries]).deep_symbolize_keys
        else
          queries = params[:queries]
        end

        manager = Reconcile::Manager.new
        items = manager.send_request(queries, credentials)

        render json: serializer.render_multiple(items), status: :ok
      end

      protected

      def serializer_class
        "CoreDataConnector::Reconcile::#{"#{controller_name}_serializer".classify}".constantize
      end

      private

      def valid_credentials?(credentials)
        return false unless credentials.present?

        parameters = %i(host protocol port api_key collection_name)
        return false unless parameters.all? { |parameter| credentials[parameter].present? }

        true
      end

    end
  end
end