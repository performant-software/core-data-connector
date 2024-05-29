require 'zip'

IGNORE_PATTERN = /\.DS_Store|__MACOSX|(^|\/)\._/

module CoreDataConnector
  class FileSystem

    # Creates a temporary directory in the Rails root/tmp folder
    def self.create_directory
      "#{Rails.root}/tmp/#{SecureRandom.urlsafe_base64}"
    end

    # Extracts the passed zip file to a temporary directory and returns the path
    def self.extract_zip(zip_file)
      # Create the target directory
      destination = create_directory
      FileUtils.mkdir_p(destination) unless File.exist? destination

      # Extract the zip file to the directory
      Zip::File.open(zip_file) do |zipfile|
        zipfile.each do |entry|
          # Ignore directories
          next unless entry.file?

          # Ignore MacOS archive
          next if entry.name =~ IGNORE_PATTERN

          # Extract the file
          zipfile.extract(entry, File.join(destination, entry.name))
        end
      end

      # Return the path of the extracted files
      destination
    end

    # Removes the passed directory
    def self.remove_directory(directory)
      FileUtils.rm_rf directory
    end

  end
end