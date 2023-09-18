module CoreDataConnector
  class RelationshipPolicy < BasePolicy
    include OwnablePolicy

    attr_reader :current_user, :relationship, :project_id

    def initialize(current_user, relationship)
      @current_user = current_user
      @relationship = relationship
      @project_id = relationship&.project_id
    end

    def permitted_attributes
      [:project_model_relationship_id, :primary_record_id, :primary_record_type, :related_record_id, :related_record_type]
    end

    class Scope < BaseScope
      def resolve
        return scope.all if current_user.admin?

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
                .joins(project: [project_models: :project_model_relationships])
                .where(ProjectModelRelationship.arel_table[:id].eq(ownable_table[:project_model_relationship_id]))
                .where(user_id: current_user.id)
                .arel
                .exists
            )
        end
      end
    end
  end
end