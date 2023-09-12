module CoreDataConnector
  module OwnableScope
    extend ActiveSupport::Concern

    included do
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