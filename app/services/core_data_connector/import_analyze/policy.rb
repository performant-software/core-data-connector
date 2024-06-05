module CoreDataConnector
  module ImportAnalyze
    class Policy

      attr_reader :current_user

      def initialize(current_user)
        @current_user = current_user
      end

      # A user can import the set of files if they are an admin or have access to the project(s) containing all of the
      # models and relationships they are attempting to import.
      def has_access?(files)
        return true if current_user.admin?

        access = true

        # Verify the user has access to all of the project_models for which they are attempting to import
        project_model_ids = project_models_query.pluck(:id)
        model_files = files.except(Import::FILE_RELATIONSHIPS)

        return false if project_model_ids.empty? && !model_files.empty?

        model_files.keys.each do |filename|
          model_files[filename][:data].each do |row|
            project_model_id = row[:import][:project_model_id]
            (access = false) and break unless project_model_ids.include?(project_model_id)
          end

          break unless access
        end

        # Verify the user has access to all of the project_model_relationships for which they are attempting to import
        project_model_relationship_ids = project_model_relationships_query.pluck(:id)
        relationships_file = files[Import::FILE_RELATIONSHIPS]

        return false if project_model_relationship_ids.empty? && !relationships_file.empty?

        relationships_file[:data].each do |row|
          project_model_relationship_id = row[:import][:project_model_relationship_id]
          (access = false) and break unless project_model_relationship_ids.include?(project_model_relationship_id)
        end

        access
      end

      private

      def project_models_query
        ProjectModel
          .where(
            Project
              .joins(:user_projects)
              .where(Project.arel_table[:id].eq(ProjectModel.arel_table[:project_id]))
              .where(user_projects: { user_id: current_user.id })
              .arel
              .exists
          )
      end

      def project_model_relationships_query
        ProjectModelRelationship
          .where(
            ProjectModel
              .joins(project: :user_projects)
              .where(
                ProjectModel.arel_table[:id].eq(ProjectModelRelationship.arel_table[:primary_model_id])
                            .or(ProjectModel.arel_table[:id].eq(ProjectModelRelationship.arel_table[:related_model_id])))
              .where(user_projects: { user_id: current_user.id })
              .arel
              .exists
          )
      end
    end
  end
end