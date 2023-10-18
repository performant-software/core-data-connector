module CoreDataConnector
  class MediaContent < ApplicationRecord
    include Ownable
    include Relateable
    include TripleEyeEffable::Resourceable
  end
end