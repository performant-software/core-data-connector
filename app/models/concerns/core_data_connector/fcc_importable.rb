module CoreDataConnector
  module FccImportable
    extend ActiveSupport::Concern

    included do
      # Generate the full URL for the record's CSV files in FairCopy.cloud
      def faircopy_cloud_url
        project = project_model.project
        return nil unless project_model.id == project.faircopy_cloud_project_model_id

        "#{project.faircopy_cloud_url}/documents/#{faircopy_cloud_id}/csv"
      end
    end
  end
end