module CoreDataConnector
  class ItemsController < ApplicationController
    # Includes
    include Http::Requestable
    include MergeableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads :source_names, only: :show

    # Search attributes
    search_attributes :name

    def analyze_import
      item = find_record(item_class)
      authorize item if authorization_valid?

      errors = nil
      data = nil

      begin
        # Download the zip file from FairCopy.cloud
        send_request(item.faircopy_cloud_url, followlocation: true) do |contents|
          # Write the contents to a temporary file
          file = Tempfile.new
          file.binmode
          file.write(contents)
          file.rewind

          # Create a temporary directory
          directory = FileSystem.create_directory

          # Extract the CSV files
          FileSystem.extract_zip(file, directory)

          # Analyze the import files
          service = ImportAnalyze::Import.new
          data = service.analyze(directory)

          # Check that the user is authorized to import all of the records in the file
          policy = ImportAnalyze::Policy.new(current_user)
          raise Pundit::NotAuthorizedError, I18n.t('errors.items_controller.authorize') unless policy.has_analyze_access?(data)

          # Remove the temporary directory
          FileSystem.remove_directory(directory)
        end
      rescue StandardError => error
        errors = [error]

        # Log the error
        log_error(error)
      end

      if errors.nil? || errors.empty?
        render json: data, status: :ok
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    def import
      item = find_record(item_class)
      authorize item if authorization_valid?

      begin
        # Check that the user is authorized to import all of the records in the file
        policy = ImportAnalyze::Policy.new(current_user)
        raise Pundit::NotAuthorizedError, I18n.t('errors.items_controller.authorize') unless policy.has_import_access?(params[:files])

        # Generate the CSV files and compress them in a ZIP
        service = ImportAnalyze::Import.new
        zip_filepath = service.create_zip(params[:files])

        # Run the importer with the new ZIP file
        zip_importer = Import::ZipHelper.new
        ok, errors = zip_importer.import_zip(zip_filepath)

        # Remove duplicates for any marked files
        service.remove_duplicates(params[:files], item.project_model.project_id)
        errors.each { |e| log_error(e) } unless errors.empty?

        # Remove the ZIP file directory
        directory = File.dirname(zip_filepath)
        FileSystem.remove_directory(directory)
      rescue StandardError => error
        errors = [error]

        # Log the error
        log_error(error)
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :bad_request
      end
    end
  end
end
