module CoreDataConnector
  class MediaContentsSerializer < BaseSerializer
    include TripleEyeEffable::ResourceableSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :name
    show_attributes :id, :name
  end
end