require 'csv'

module CoreDataConnector
  module Import
    class Base
      attr_reader :filepath, :project_model_id, :table_name, :user_defined_columns, :user_defined_fields

      def initialize(project_model_id, filepath)
        @project_model_id = project_model_id
        @filepath = filepath

        @connection = ActiveRecord::Base.connection
        @table_name = create_table_name
        @user_defined_fields = load_user_defined_fields
        @user_defined_columns = load_user_defined_columns
      end

      def run
        # Setup the temporary table
        setup

        # Extract the CSV to the temporary table
        extract

        # Transform any columns
        transform

        # Load the data into the target table
        load

        # Drop the temporary table
        cleanup
      end

      protected

      def cleanup
        execute <<-SQL.squish
          DROP TABLE IF EXISTS #{table_name}
        SQL
      end

      def execute(sql)
        @connection.execute sql
      end

      def extract
        columns = [*column_names, *user_defined_columns]
        column_names = columns.map{ |column| column[:name] }.join(', ')

        execute <<-SQL.squish
          COPY #{table_name} ( #{column_names} )
          FROM '#{filepath}'
          DELIMITER ','
          CSV HEADER
        SQL
      end

      def load
        # Implemented in sub-classes
      end

      def setup
        columns = [*column_names, *user_defined_columns]
        column_names = columns.map{ |column| "#{column[:name]} #{column[:type]}" }.join(', ')

        execute <<-SQL.squish
          CREATE TABLE #{table_name} (
            id SERIAL,
            #{column_names}
          )
        SQL
      end

      def table_name_prefix
        # Implemented in sub-classes
      end

      def transform
        # Implemented in sub-classes
      end

      def user_defined_expression
        expression = []

        user_defined_columns.each do |column|
          key = column[:name].gsub('udf_', '')
          user_defined_field = user_defined_fields[key]

          next if user_defined_field.nil?

          expression << "'#{user_defined_field[:uuid]}'"
          expression << column[:name]
        end

        return "'{}'" if expression.empty?

        "json_build_object(#{expression.join(', ')})"
      end

      private

      def create_table_name
        "#{table_name_prefix}_#{Random.rand(1000..9999)}"
      end

      def load_user_defined_fields
        UserDefinedFields::UserDefinedField
          .where(defineable_id: 30)
          .where(defineable_type: CoreDataConnector::ProjectModel.to_s)
          .pluck(:column_name, :id, :uuid)
          .inject({}) do |hash, element|
            key = element[0].parameterize(separator: '_')
            value = { id: element[1], uuid: element[2] }

            hash.merge!(key => value)
          end
      end

      def load_user_defined_columns
        columns = []

        headers = CSV.foreach(filepath).first

        headers.each do |header|
          next unless header.starts_with?('udf_')

          columns << {
            name: header,
            type: 'VARCHAR'
          }
        end

        columns
      end
    end
  end
end