module CoreDataConnector
  class MediaContent < ApplicationRecord
    # Includes
    include Identifiable
    include Ownable
    include Relateable
    include Search::MediaContent
    include TripleEyeEffable::Resourceable
    include UserDefinedFields::Fieldable

    # User defined fields parent
    resolve_defineable -> (media_content) { media_content.project_model }
  end
end