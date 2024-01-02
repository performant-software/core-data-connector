module CoreDataConnector
  module Search
    module Item
      extend ActiveSupport::Concern

      class_methods do
        def preloads
          [:primary_name, source_titles: :name]
        end
      end

      included do
        # Includes
        include Base

        search_attribute(:name) do
          primary_name.name.name
        end

        search_attribute(:names) do
          source_titles.map { |st| st.name.name }
        end
      end

    end
  end
end