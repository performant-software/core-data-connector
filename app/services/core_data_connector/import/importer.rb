module CoreDataConnector
  module Import
    class Importer
      attr_reader :importers, :import_id

      IMPORTERS = [{
        importer_class: Events,
        filename: 'events.csv'
      }, {
        importer_class: Instances,
        filename: 'instances.csv'
      }, {
        importer_class: Items,
        filename: 'items.csv'
      }, {
        importer_class: MediaContent,
        filename: 'media_contents.csv'
      }, {
        importer_class: Organizations,
        filename: 'organizations.csv'
      }, {
        importer_class: People,
        filename: 'people.csv'
      }, {
        importer_class: Places,
        filename: 'places.csv'
      }, {
        importer_class: Taxonomies,
        filename: 'taxonomies.csv'
      }, {
        importer_class: Works,
        filename: 'works.csv'
      }]

      # Importers that reference any of the above models
      RELATIONSHIP_IMPORTERS = [{
        importer_class: Relationships,
        filename: 'relationships.csv'
      }, {
        importer_class: WebIdentifiers,
        filename: 'web_identifiers.csv'
      }]

      def initialize(directory)
        @importers = []
        @import_id = SecureRandom.uuid

        IMPORTERS.each do |importer|
          populate_importer(importer, directory)
        end

        RELATIONSHIP_IMPORTERS.each do |importer|
          populate_importer(importer, directory)
        end
      end

      def close
        # Iterate over each importer and perform any cleanup
        importers.each do |importer|
          importer.cleanup
        end
      end

      def run
        importers.each do |importer|
          # Setup necessary schema
          importer.setup

          # Extract the files from the CSV to the temp table
          importer.extract

          # Transform any values
          importer.transform

          # Load the data into the appropriate tables
          importer.load
        end

        # Upload any attachments for media_contents
        upload_attachments

        # Return the import ID
        import_id
      end

      private

      def populate_importer(importer, directory)
        filename = importer[:filename]
        klass = importer[:importer_class]

        filepath = "#{directory}/#{filename}"

        if File.exist? filepath
          @importers << klass.new(filepath, import_id)
        end
      end

      def upload_attachments
        query = CoreDataConnector::MediaContent
                  .where(import_id:)
                  .where.not(import_url: nil)
                  .where.not(import_url_processed: true)

        query.find_each { |m| upload_attachment m }
      end

      def upload_attachment(media_content)
        media_content.content = ActionDispatch::Http::UploadedFile.new(
          tempfile: Http::Stream.new(media_content.import_url, followlocation: true).download,
          filename: media_content.name
        )

        media_content.import_url_processed = true

        media_content.save
      end
    end
  end
end
