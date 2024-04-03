module CoreDataConnector
  class ItemPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :item, :project_model_id, :project_id

    def initialize(current_user, item)
      @current_user = current_user
      @item = item

      @project_model_id = item&.project_model_id
      @project_id = item&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      [ *ownable_attributes,
        :faircopy_cloud_id,
        user_defined: {},
        source_titles_attributes: [:id, :primary, :name_id, :_destroy, name_attributes: [:id, :name]]
      ]
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end