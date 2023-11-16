module CoreDataConnector
  module ImportableController
    extend ActiveSupport::Concern

    included do
      def import
        render json: { errors: ['Importable contents required'] }, status: 400 and return unless params[:file].present? && params[:project_model_id].present?

        begin
          project_model_id = params[:project_model_id]
          filepath = params[:file].tempfile.path

          importer_class = importer_name.constantize
          importer = importer_class.new(project_model_id, filepath)

          item_class.transaction do
            importer.run
          end
        rescue ActiveRecord::RecordInvalid => exception
          errors = [exception]
        rescue StandardError => exception
          errors = [exception]
        end

        if errors.nil? || errors.empty?
          render json: { }, status: :ok
        else
          render json: { errors: errors }, status: 422
        end
      end

      private

      def importer_name
        "CoreDataConnector::Import::#{controller_name.capitalize}"
      end
    end
  end
end