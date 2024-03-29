require 'zip'

IGNORE_PATTERN = /\.DS_Store|__MACOSX|(^|\/)\._/

module CoreDataConnector
  module ImportableController
    extend ActiveSupport::Concern

    included do
      def import(temp_file)
        begin
          # Create the target directory
          destination = "#{Rails.root}/tmp/#{SecureRandom.urlsafe_base64}"
          FileUtils.mkdir_p(destination) unless File.exist? destination

          # Extract the zip file to the directory
          Zip::File.open(temp_file) do |zipfile|
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

          return true, []
        rescue ActiveRecord::RecordInvalid => exception
          return false, [exception]
        rescue StandardError => exception
          return false, [exception]
        end
      end
    end
  end
end