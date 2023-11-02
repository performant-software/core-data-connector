module CoreDataConnector
  module Ownable
    extend ActiveSupport::Concern

    included do
      # Relationships
      belongs_to :project_model

      # Delegates
      delegate :project_id, to: :project_model, allow_nil: true

      # Returns a query to find all of the records owned by the passed project_model_id or shared with the
      # passed project_model_id.
      def self.all_records_by_project_model(project_model_id)
        owned_query = owned_records_by_project_model(project_model_id)
        shared_query = shared_records_by_project_model(project_model_id)

        owned_query.or(shared_query)
      end

      # Returns a query to find all of the records owned by the passed project_model_id.
      def self.owned_records_by_project_model(project_model_id)
        where(project_model_id: project_model_id)
      end

      # Returns a query to find all of the records shared with the passed project_model_id.
      def self.shared_records_by_project_model(project_model_id)
        where(
          ProjectModelShare
            .joins(:project_model_access)
            .where(ProjectModelAccess.arel_table[:project_model_id].eq(self.arel_table[:project_model_id]))
            .where(project_model_id: project_model_id)
            .arel
            .exists
        )
      end
    end
  end
end