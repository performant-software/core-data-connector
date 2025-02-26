module CoreDataConnector
  class Taxonomy < ApplicationRecord
    # Includes
    include Export::Taxonomy
    include Identifiable
    include ImportAnalyze::Taxonomy
    include Manifestable
    include Mergeable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable
    include Search::Taxonomy
  end
end
