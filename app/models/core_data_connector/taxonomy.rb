module CoreDataConnector
  class Taxonomy < ApplicationRecord
    # Includes
    include Export::Taxonomy
    include Identifiable
    include Manifestable
    include Mergeable
    include Ownable
    include Relateable
    include Search::Taxonomy
  end
end
