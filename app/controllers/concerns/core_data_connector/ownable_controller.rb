module CoreDataConnector
  module OwnableController
    extend ActiveSupport::Concern

    included do
      protected

      def base_query
        query = super

        # For a single record, we don't need to owner_id or owner_type
        return query if params[:id].present?

        # For an index query, require the owner_id and owner_type
        return item_class.none unless params[:project_model_id].present?

        query.where(project_model_id: params[:project_model_id])
      end
    end
  end
end