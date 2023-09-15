module CoreDataConnector
  module OwnablePolicy
    extend ActiveSupport::Concern

    included do
      # A user can create an owned record for projects of which they are a member.
      def create?
        return true if current_user.admin?

        member?
      end

      # A user can delete an owned record if they are a member of the owning project.
      def destroy?
        return true if current_user.admin?

        member?
      end

      # A user can view an owned record if they are a member of the owning project.
      def show?
        return true if current_user.admin?

        member?
      end

      # A user can update an owned record if they are a member of the owning project.
      def update?
        return true if current_user.admin?

        member?
      end

      def ownable_attributes
        [ :project_model_id ]
      end

      # Returns true if the current user has a `user_projects` record for the owned item's `project_item`.
      def member?
        current_user
          .user_projects
          .where(project_id: project_id)
          .exists?
      end
    end
  end
end