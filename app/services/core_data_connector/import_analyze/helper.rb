module CoreDataConnector
  module ImportAnalyze
    class Helper

      PREFIX_USER_DEFINED = 'udf_'

      PRELOADS = [
        :project_model,
        relationships: [:related_record, project_model_relationship: :user_defined_fields],
        related_relationships: [:primary_record, project_model_relationship: :user_defined_fields],
      ]

      def self.column_name_to_uuid(column_name)
        column_name.gsub(PREFIX_USER_DEFINED, '').gsub('_', '-')
      end

      def self.is_user_defined_column?(column_name)
        column_name.starts_with?(PREFIX_USER_DEFINED)
      end

      def self.user_defined_columns(filepath)
        CSV.foreach(filepath).first.select{ |h| is_user_defined_column?(h) }
      end

      def self.uuid_to_column_name(uuid)
        "#{PREFIX_USER_DEFINED}#{uuid.gsub('-', '_')}"
      end

      def analyze(zip, user)
        # Create a temporary directory
        directory = FileSystem.create_directory

        # Extract the CSV files
        FileSystem.extract_zip(zip, directory)

        # Analyze the import files
        service = Import.new
        data = service.analyze(directory)

        # Check that the user is authorized to import all of the records in the file
        policy = Policy.new(user)
        raise Pundit::NotAuthorizedError, I18n.t('errors.import.authorize') unless policy.has_analyze_access?(data)

        # Remove the temporary directory
        FileSystem.remove_directory(directory)

        data
      end

      def import(files, user, project_id)
        # Check that the user is authorized to import all of the records in the file
        policy = Policy.new(user)
        raise Pundit::NotAuthorizedError, I18n.t('errors.import.authorize') unless policy.has_import_access?(files)

        # Generate the CSV files and compress them in a ZIP
        service = Import.new
        zip_filepath = service.create_zip(files)

        # Run the importer with the new ZIP file
        zip_importer = CoreDataConnector::Import::ZipHelper.new
        ok, errors = zip_importer.import_zip(zip_filepath)

        # Remove duplicates for any marked files
        service.remove_duplicates(files, project_id)

        # Remove the ZIP file directory
        directory = File.dirname(zip_filepath)
        FileSystem.remove_directory(directory)

        errors
      end
    end
  end
end