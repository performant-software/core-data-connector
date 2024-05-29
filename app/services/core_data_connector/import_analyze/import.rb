require 'csv'

module CoreDataConnector
  module ImportAnalyze
    class Import

      def analyze(directory)
        # TODO: Check authorization somewhere?

        data = {}

        pattern = File.join(directory, "*.csv")

        Dir.glob(pattern).each do |filepath|
          filename = File.basename(filepath)
          klass = find_class(filename)

          attributes = klass.export_attributes.map{ |a| a[:name] } unless klass.nil?
          records_by_uuid = find_records_by_uuid(filepath, klass)

          CSV.foreach(filepath, headers: true, converters: [:numeric]) do |row|
            data[filename] ||= { attributes: attributes, data: [] }

            row_hash = row.to_h.symbolize_keys
            record = records_by_uuid[row_hash[:uuid]]

            data[filename][:data] << {
              import: row_hash,
              db: record&.to_export_csv
            }
          end
        end

        data
      end

      private

      def apply_preloads(klass, records)
        # Preload any associations from the concrete class
        if klass.respond_to?(:export_preloads) && klass.export_preloads.present?
          Preloader.new(
            records: records,
            associations: klass.export_preloads
          ).call
        end
      end

      def find_class(filename)
        "CoreDataConnector::#{File.basename(filename, '.csv').singularize.capitalize}".classify.constantize
      end

      def find_records_by_uuid(filepath, klass)
        records_by_uuid = {}

        uuids = []

        CSV.foreach(filepath, headers: true, converters: [:numeric]) do |row|
          uuids << row.to_h.symbolize_keys[:uuid]
        end

        query = klass.all
        query = query.merge(klass.export_query) if klass.respond_to?(:export_query)
        query = query.where(uuid: uuids)

        query.find_in_batches(batch_size: 1000) do |records|
          apply_preloads klass, records

          records.each do |record|
            records_by_uuid[record.uuid] = record
          end
        end

        records_by_uuid
      end
    end
  end
end