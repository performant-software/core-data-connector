module CoreDataConnector
  module MergeableController
    extend ActiveSupport::Concern

    included do

      def merge
        render json: { errors: [I18n.t('errors.mergeable.ids')] }, status: :bad_request and return unless params[:ids].present?

        item = item_class.new(prepare_params)
        authorize_create item

        # preloads = [
        #   :project_model,
        #   relationships: [:related_record, project_model_relationship: :user_defined_fields],
        #   related_relationships: [:primary_record, project_model_relationship: :user_defined_fields],
        # ]

        items = item_class
                  .preload(ImportAnalyze::Helper::PRELOADS)
                  .where(id: params[:ids])

        authorize_destroy items

        begin
          service = Merge::Merger.new
          service.merge(item, items)

          errors = item.errors
        rescue StandardError => exception
          errors = [exception]
        end

        if errors.nil? || errors.empty?
          render json: build_show_response(item), status: :ok
        else
          render json: { errors: errors }, status: :bad_request
        end
      end

      private

      def authorize_create(item)
        policy = Pundit.policy!(current_user, item)
        policy.create?
      end

      def authorize_destroy(items)
        items.each do |item|
          policy = Pundit.policy!(current_user, item)
          policy.destroy?
        end
      end
    end
  end
end