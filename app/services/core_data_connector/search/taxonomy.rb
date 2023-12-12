module CoreDataConnector
  module Search
    module Taxonomy
      extend ActiveSupport::Concern

      included do
        # Includes
        include Base

        # Search attributes
        search_attribute :name
      end
    end
  end
end