require 'zip'

module CoreDataConnector
  class ItemsController < ApplicationController
    # Includes
    include MergeableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads source_titles: :name

    # Joins
    joins primary_name: :name

    def analyze_import
      item = find_record(item_class)
      authorize item if authorization_valid?

      errors = nil

      begin
        # Download the zip file from FairCopy.cloud
        file = File.open('/Users/dleadbetter/Performant/core-data/import-fcc/Archive.zip')

        # Extract the CSV files
        directory = FileSystem.extract_zip(file)

        # Analyze the import files
        service = ImportAnalyze::Import.new
        data = service.analyze(directory)

        # Remove the temporary directory
        FileSystem.remove_directory(directory)
      rescue StandardError => exception
        errors = [exception]
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

      # TODO: Authorize user to import each item in the CSV

      begin
        # Generate the CSV files and compress them in a ZIP
        service = ImportAnalyze::Import.new
        zip_filepath = service.create_zip(params[:files])

        # Run the importer with the new ZIP file
        zip_importer = Import::ZipHelper.new
        ok, errors = zip_importer.import_zip(zip_filepath)

        # Remove the ZIP file directory
        directory = File.dirname(zip_filepath)
        FileSystem.remove_directory(directory)
      rescue StandardError => exception
        errors = [exception]
      end

      if errors.nil? || errors.empty?
        render json: { }, status: :ok
      else
        render json: { errors: errors }, status: :bad_request
      end
    end
  end
end
