module CoreDataConnector
  class Taxonomy < ApplicationRecord
    # Includes
    include Identifiable
    include Manifestable
    include Ownable
    include Relateable
    include Search::Taxonomy
  end
end
