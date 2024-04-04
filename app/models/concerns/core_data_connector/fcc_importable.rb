module CoreDataConnector
  module FccImportable
    extend ActiveSupport::Concern
    include Http::Requestable

    included do
      after_create :fcc_import
      
      CODE_NO_RESPONSE = 0

      # Generate the full URL for the record's CSV files in FairCopy.cloud
      def faircopy_cloud_url(project)
        if !self[:faircopy_cloud_id] || !project[:faircopy_cloud_url]
          return nil
        end

        "#{project[:faircopy_cloud_url]}/documents/#{self[:faircopy_cloud_id]}/csv"
      end

      def fcc_import
        project = Project.find(self.project_id)

        url = self.faircopy_cloud_url(project)

        if !url
          return nil
        end

        project_model = self.project_model

        if project.faircopy_cloud_project_model_id != project_model.id
          return nil
        end

        send_request(url, followlocation: true) do |file_string|
          tempfile = Tempfile.new
          tempfile.binmode
          tempfile.write(file_string)
          tempfile.rewind
  
          zip_importer = Import::ZipHelper.new
          ok, errors = zip_importer.import_zip(tempfile)
  
          if errors && !errors.empty?
            puts "Errors importing records for #{url}:"
            puts errors.inspect
          end
        end
      end
    end
  end
end