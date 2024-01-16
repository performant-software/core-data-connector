module CoreDataConnector
  class Taxonomy < ApplicationRecord
    include Identifiable
    include Ownable
    include Relateable
    include Search::Taxonomy
  end
end
