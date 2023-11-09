module CoreDataConnector
  class MediaContentPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :media_content, :project_model_id, :project_id

    def initialize(current_user, media_content)
      @current_user = current_user
      @media_content = media_content

      @project_model_id = media_content&.project_model_id
      @project_id = media_content&.project_id
    end

    # Allowed create/update attributes.
    def permitted_attributes
      [ *ownable_attributes,
        :name,
        :content,
        user_defined: {}
      ]
    end

    # Include default ownable scope.
    class Scope < BaseScope
      include OwnableScope
    end
  end
end