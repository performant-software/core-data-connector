require 'csv'

module CoreDataConnector
  module Import
    class Base
      attr_reader :filepath, :table_name, :user_defined_columns

      def initialize(filepath)
        @filepath = filepath

        @connection = ActiveRecord::Base.connection
        @table_name = create_table_name
        @user_defined_columns = load_user_defined_columns
      end

      def cleanup
        execute <<-SQL.squish
          DROP TABLE IF EXISTS #{table_name}
        SQL
      end

      def extract
        column_names = columns
                         .select{ |c| c[:copy] == true }
                         .map{ |column| column[:name] }.join(', ')

        options = "FORMAT CSV, DELIMITER ','"
        copy_command = "COPY #{table_name} (#{column_names}) FROM STDIN WITH (#{options})"

        @connection.raw_connection.copy_data(copy_command)  do
          CSV.foreach(filepath, headers: true) do |row|
            @connection.raw_connection.put_copy_data(row.to_csv)
          end
        end
      end

      def load
        # Implemented in sub-classes
      end

      def setup
        column_names = columns
                         .map{ |column| "#{column[:name]} #{column[:type]}" }
                         .join(', ')

        execute <<-SQL.squish
          CREATE TABLE #{table_name} (
            id SERIAL,
            #{column_names}
          )
        SQL
      end

      def transform
        # Sets the user_defined column based on any included user-defined fields
        expression = user_defined_columns
                       .map{ |c| ["'#{column_name_to_uuid(c[:name])}'", c[:name]] }
                       .flatten
                       .join(', ')

        execute <<-SQL.squish
          UPDATE #{table_name}
             SET user_defined = json_strip_nulls(json_build_object(#{expression}))
        SQL
      end

      protected

      def execute(sql)
        @connection.execute sql
      end

      def table_name_prefix
        # Implemented in sub-classes
      end

      private

      def columns
        [ *column_names, *user_defined_columns ]
      end

      # Converts the passed colum name to a UUID value.
      def column_name_to_uuid(column_name)
        column_name.gsub('_', '-')[1..-1]
      end

      def create_table_name
        "#{table_name_prefix}_#{Random.rand(1000..9999)}"
      end

      def load_user_defined_columns
        columns = []

        headers = CSV.foreach(filepath).first

        headers.each do |header|
          next unless header.starts_with?('udf_')
          uuid = header.gsub('udf_', '')

          columns << {
            name: uuid_to_column_name(uuid),
            type: 'VARCHAR',
            copy: true
          }
        end

        columns
      end

      # Converts the passed UUID value to a database-safe column name
      def uuid_to_column_name(uuid)
        "_#{uuid.gsub('-', '_')}"
      end
    end
  end
end