module CoreDataConnector
  module OwnableScope
    extend ActiveSupport::Concern

    included do
      def resolve
        return scope.all if current_user.admin?

        if scope.is_a?(Class)
          ownable_table = scope.arel_table
        elsif scope.is_a?(ActiveRecord::Relation)
          ownable_table = scope.klass.arel_table
        end

        scope
          .where(
            UserProject
              .joins(project: :project_models)
              .where(ProjectModel.arel_table[:id].eq(ownable_table[:project_model_id]))
              .where(user_id: current_user.id)
              .arel
              .exists
          )
      end
    end
  end
end