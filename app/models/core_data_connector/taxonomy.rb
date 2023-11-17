module CoreDataConnector
  class Taxonomy < ApplicationRecord
    include Ownable
    include Relateable
  end
end
