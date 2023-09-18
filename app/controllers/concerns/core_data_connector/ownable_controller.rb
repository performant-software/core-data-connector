module CoreDataConnector
  module OwnableController
    extend ActiveSupport::Concern

    included do
      protected

      def base_query
        query = super

        # For a single record, we don't need to owner_id or owner_type
        return query if params[:id].present?

        if params[:project_model_id].present?
          query.where(project_model_id: params[:project_model_id])
        elsif params[:project_id].present?
          query.joins(:project_model).where(core_data_connector_project_models: { project_id: params[:project_id] })
        else
          item_class.none
        end
      end
    end
  end
end