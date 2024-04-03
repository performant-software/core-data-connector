module CoreDataConnector
  module FccImportable
    extend ActiveSupport::Concern

    included do
      after_create :fcc_import
      
      CODE_NO_RESPONSE = 0

      # Generate the full URL for the record's CSV files in FairCopy.cloud
      def faircopy_cloud_url
        if !self[:faircopy_cloud_id]
          return nil
        end

        project = self.project_model.project

        if !project[:faircopy_cloud_url]
          return nil
        end

        "#{project[:faircopy_cloud_url]}/documents/#{self[:faircopy_cloud_id]}/csv"
      end

      def fetch_csv_zip
        url = self.faircopy_cloud_url

        if !url
          return nil
        end

        request = Typhoeus::Request.new(url, followlocation: true)

        response = request.run

        if response.success?
          return response.body
        elsif response.timed_out?
          { error: I18n.t('errors.http.timeout') }
        elsif response.code == CODE_NO_RESPONSE
          { error: I18n.t('errors.http.no_response') }
        else
          { error: I18n.t('errors.http.general') }
        end
      end

      def fcc_import
        project = Project.find(self.project_id)
        project_model = self.project_model

        if project.faircopy_cloud_project_model_id != project_model.id
          return nil
        end

        file_string = self.fetch_csv_zip

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write(file_string)
        tempfile.rewind

        zip_importer = Import::ZipHelper.new
        ok, errors = zip_importer.import_zip(tempfile)

        if errors && !errors.empty?
          puts "Errors importing records for #{self.faircopy_cloud_id}:"
          puts errors.inspect
        end
      end
    end
  end
end