module CoreDataConnector
  class MediaContentsSerializer < BaseSerializer
    include TripleEyeEffable::ResourceableSerializer

    index_attributes :id, :name
    show_attributes :id, :name
  end
end