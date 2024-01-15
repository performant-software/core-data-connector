module CoreDataConnector
  module Import
    class Importer
      attr_reader :importers

      IMPORTERS = [{
        importer_class: Instances,
        filename: 'instances.csv'
      }, {
        importer_class: Items,
        filename: 'items.csv'
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
        importer_class: Works,
        filename: 'works.csv'
      }, {
        importer_class: Relationships,
        filename: 'relationships.csv'
      }]

      def initialize(directory)
        @importers = []

        IMPORTERS.each do |importer|
          filename = importer[:filename]
          klass = importer[:importer_class]

          filepath = "#{directory}/#{filename}"
          next unless File.exist? filepath

          @importers << klass.new(filepath)
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

        # Iterate over each importer and perform any cleanup
        importers.each do |importer|
          importer.cleanup
        end
      end
    end
  end
end
