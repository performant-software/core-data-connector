module CoreDataConnector
  class WebAuthorityPolicy < BasePolicy
    attr_reader :current_user, :web_authority, :project_id

    def initialize(current_user, web_authority)
      @current_user = current_user
      @web_authority = web_authority
      @project_id = web_authority&.project_id
    end

    # A user can create a web authority if they are an admin user or the owner of the project.
    def create?
      return true if current_user.admin?

      owner?
    end

    # A user can delete a web authority if they are an admin user or the owner of the project.
    def destroy?
      return true if current_user.admin?

      owner?
    end

    # A user can view a web authority if they are an admin user or the owner of the project.
    def show?
      return true if current_user.admin?

      owner?
    end

    # A user can update a web authority if they are an admin user or the owner of the project.
    def update?
      return true if current_user.admin?

      owner?
    end

    def permitted_attributes
      [:project_id, :source_type, access: {}]
    end

    private

    # Returns true if the current user has an owner `user_projects` record for the web authority's project.
    def owner?
      current_user
        .user_projects
        .where(project_id: project_id)
        .where(role: UserProject::ROLE_OWNER)
        .exists?
    end

    # A user can view web authorities for any project they own.
    class Scope < BaseScope
      def resolve
        return scope.all if current_user.admin?

        scope.where(
          UserProject
            .where(UserProject.arel_table[:project_id].eq(WebAuthority.arel_table[:project_id]))
            .where(user_id: current_user.id)
            .where(role: UserProject::ROLE_OWNER)
            .arel
            .exists
        )
      end
    end
  end
end