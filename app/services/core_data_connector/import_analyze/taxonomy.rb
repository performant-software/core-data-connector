module CoreDataConnector
  module ImportAnalyze
    module Taxonomy
      extend ActiveSupport::Concern

      # Includes
      include Base

      class_methods do
        def group_by_columns
          [:name]
        end
      end
    end
  end
end