require 'zip'

IGNORE_PATTERN = /\.DS_Store|__MACOSX|(^|\/)\._/

module CoreDataConnector
  class ProjectsController < ApplicationController
    # Search attributes
    search_attributes :name

    def clear
      project = Project.find(params[:id])
      authorize project, :clear?

      # Query for models that are not shared with other projects
      project_models = ProjectModel
                         .unshared
                         .where(project_id: project.id)

      begin
        project_models.map(&:clear)
      rescue StandardError => exception
        errors = [exception]
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    def export_configuration
      project = Project.find(params[:id])
      authorize project, :export_configuration?

      options = load_records(project)
      serializer = ProjectConfigurationsSerializer.new(current_user, options)

      json = { param_name.to_sym => serializer.render_show(project) }
      render json: json, status: :ok
    end

    def import_configuration
      render json: { errors: [I18n.t('errors.projects.import_configuration')] }, status: :bad_request and return unless params[:file].present?

      project = Project.find(params[:id])
      authorize project, :import_configuration?

      begin
        service = Configuration.new(project, params[:file])
        service.import_configuration
      rescue StandardError => exception
        errors = [exception]
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end

    def import_data
      render json: { errors: [I18n.t('errors.projects.import_data')] }, status: :bad_request and return unless params[:file].present?

      project = Project.find(params[:id])
      authorize project, :import_data?

      begin
        # Create the target directory
        destination = "#{Rails.root}/tmp/#{SecureRandom.urlsafe_base64}"
        FileUtils.mkdir_p(destination) unless File.exist? destination

        # Extract the zip file to the directory
        Zip::File.open(params[:file].tempfile.path) do |zipfile|
          zipfile.each do |entry|
            # Ignore directories
            next unless entry.file?

            # Ignore MacOS archive
            next if entry.name =~ IGNORE_PATTERN

            # Extract the file
            zipfile.extract(entry, File.join(destination, entry.name))
          end
        end

        # Create a new importer with the temp directory and run it
        ActiveRecord::Base.transaction do
          importer = Import::Importer.new(destination)
          importer.run
        end

        # Remove the temporary directory
        FileUtils.rm_rf(destination)
      rescue ActiveRecord::RecordInvalid => exception
        errors = [exception]
      rescue StandardError => exception
        errors = [exception]
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end

    protected

    # If we're not looking for "discoverable" projects, use base query defined by the policy. Otherwise, return
    # a query to find all discoverable projects not matching the current project.
    def base_query
      return super unless params[:discoverable].to_s.to_bool && params[:project_id].present?

      Project
        .where(discoverable: true)
        .where.not(id: params[:project_id])
    end

    # Automatically add the user who created the project as the owner, if they are not an admin.
    def after_create(project)
      return if current_user.admin?

      UserProject.create(
        project_id: project.id,
        user_id: current_user.id,
        role: UserProject::ROLE_OWNER
      )
    end

    private

    def create_importer(filepath)
      filename = File.basename(filepath, '.csv')

      importer_class = "CoreDataConnector::Import::#{filename.capitalize}".constantize
      importer_class.new(filepath)
    end
  end
end