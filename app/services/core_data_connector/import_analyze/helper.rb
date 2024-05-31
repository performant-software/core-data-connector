module CoreDataConnector
  module ImportAnalyze
    class Helper

      PREFIX_USER_DEFINED = 'udf_'

      def self.column_name_to_uuid(column_name)
        column_name.gsub(PREFIX_USER_DEFINED, '').gsub('_', '-')
      end

      def self.is_user_defined_column?(column_name)
        column_name.starts_with?(PREFIX_USER_DEFINED)
      end

      def self.user_defined_columns(filepath)
        CSV.foreach(filepath).first.select{ |h| is_user_defined_column?(h) }
      end

      def self.uuid_to_column_name(uuid)
        "#{PREFIX_USER_DEFINED}#{uuid.gsub('-', '_')}"
      end
    end
  end
end