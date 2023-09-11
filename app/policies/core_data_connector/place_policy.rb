module CoreDataConnector
  class PlacePolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :place

    def initialize(current_user, place)
      @current_user = current_user
      @place = place
    end

    # A user can create a place for projects of which they are a member.
    def create?
      return true if current_user.admin?

      member?
    end

    # A user can delete a place if they are a member of the owning project
    def delete?
      return true if current_user.admin?

      member?
    end

    # A user can view a place if they are a member of the owning project
    def show?
      return true if current_user.admin?

      member?
    end

    # A user can update a place if they are a member of the owning project
    def update?
      return true if current_user.admin?

      member?
    end

    # Allowed create/update attributes.
    def permitted_attributes
      attrs = super
      attrs << { place_names_attributes: [:id, :name, :primary, :_destroy] }
      attrs
    end

    private

    # Returns true if the current user has a `user_projects` record for the place's `project_item`.
    def member?
      current_user
        .user_projects
        .where(project_id: place.project_item.project_id)
        .exists?
    end

    # Users can view a place if they are a member of the project that owns it.
    class Scope < BaseScope
      def resolve
        return scope.all if current_user.admin?

        scope
          .joins(:project_item)
          .where(
            UserProject
              .where(UserProject.arel_table[:project_id].eq(ProjectItem.arel_table[:project_id]))
              .where(user_id: current_user.id)
              .arel
              .exists
          )
      end
    end
  end
end