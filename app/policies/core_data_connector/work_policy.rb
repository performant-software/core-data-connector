module CoreDataConnector
  class WorkPolicy < BasePolicy
    # Includes
    include MergeablePolicy
    include OwnablePolicy

    attr_reader :current_user, :work, :project_model_id, :project_id

    def initialize(current_user, work)
      @current_user = current_user
      @work = work

      @project_model_id = work&.project_model_id
      @project_id = work&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      [ *ownable_attributes,
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
