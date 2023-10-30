module CoreDataConnector
  module OwnableController
    extend ActiveSupport::Concern

    included do
      protected

      def base_query
        query = super

        # For a single record, we don't need to owner_id or owner_type
        return query if params[:id].present?

        # Return an empty set if the project_model_id is not present
        return item_class.none unless params[:project_model_id].present?

        query.where(project_model_id: params[:project_model_id])
      end
    end
  end
end