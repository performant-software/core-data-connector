module CoreDataConnector
  class Taxonomy < ApplicationRecord
    include Ownable
    include Relateable
    include Search::Taxonomy
  end
end
