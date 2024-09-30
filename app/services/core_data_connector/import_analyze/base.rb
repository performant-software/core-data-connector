module CoreDataConnector
  module ImportAnalyze
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def base_query
          all
        end

        def group_by_columns
          # Implemented in sub-classes
        end

        def find_duplicates(import_id)
          primary_key = "#{table_name}.id"

          select_columns = [
            *group_by_columns,
            "MIN(#{primary_key}) AS primary_id",
            "ARRAY_REMOVE(ARRAY_AGG(#{primary_key}), MIN(#{primary_key})) AS duplicate_ids"
          ]

          base_query
            .select(select_columns)
            .where(import_id: import_id)
            # .where(project_model_id: 34)
            .group(group_by_columns)
            .having('COUNT(*) > 1')
        end

      end
    end
  end
end