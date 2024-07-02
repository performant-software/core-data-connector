require 'csv'

module CoreDataConnector
  module Export
    class Exporter

      attr_reader :project_id

      EXPORT_CLASSES = [{
        class: CoreDataConnector::Event,
        filename: 'events.csv'
      }, {
        class: CoreDataConnector::Item,
        filename: 'items.csv'
     }, {
        class: CoreDataConnector::Instance,
        filename: 'instances.csv'
     }, {
        class: CoreDataConnector::Organization,
        filename: 'organizations.csv'
      }, {
        class: CoreDataConnector::Person,
        filename: 'people.csv'
      }, {
        class: CoreDataConnector::Place,
        filename: 'places.csv'
      }, {
        class: CoreDataConnector::Relationship,
        filename: 'relationships.csv'
      }, {
        class: CoreDataConnector::Taxonomy,
        filename: 'taxonomies.csv'
      }, {
        class: CoreDataConnector::Work,
        filename: 'works.csv'
      }]

      def initialize(project_id)
        @project_id = project_id
      end

      def run(directory)
        user_defined_fields = build_user_defined_fields

        EXPORT_CLASSES.each do |klass|
          model_class = klass[:class]
          filename = klass[:filename]

          filepath = File.join(directory, filename)

          # Query all of the records owned or shared with the passed project
          query = model_class.all_records_by_project(project_id)
          query = query.merge(model_class.export_query) if model_class.respond_to?(:export_query)

          # Skip this model class if the project does not contain any relevant data
          next unless query.count(Arel.star) > 0

          user_defined_field_uuids = user_defined_fields[model_class.to_s] || []
          headers = find_headers(model_class, user_defined_field_uuids)

          CSV.open(filepath, 'w', headers: headers, write_headers: true) do |csv|
            query.find_in_batches(batch_size: 1000) do |records|

              # Apply any preloads for the current model/batch
              apply_preloads model_class, records

              # Iterate over each record and convert it to a CSV row
              records.each do |record|
                csv_row = record.to_export_csv

                # Add the user-defined field properties to the hash. The list of user-defined field UUIDs will contain
                # the complete set of all user-defined fields across all models for the current type.
                user_defined_field_uuids.each do |uuid|
                  value = record.user_defined[uuid] if record.user_defined.present?
                  csv_row[uuid] = value
                end

                csv << csv_row.values
              end
            end
          end
        end
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

      def build_user_defined_fields
        query = Queries
                  .all_fields_by_project(project_id)
                  .group(:table_name, :uuid)
                  .pluck(:table_name, :uuid)

        query.inject({}) do |h, v|
          uuid, value = v

          h[uuid] ||= []
          h[uuid] << value

          h
        end
      end

      def find_headers(klass, user_defined_field_uuids)
        headers = klass.export_attributes.map{ |a| a[:name].to_s }

        user_defined_field_uuids.each do |uuid|
          headers << ImportAnalyze::Helper.uuid_to_column_name(uuid)
        end

        headers
      end

    end
  end
end