module CoreDataConnector
  module Public
    class MediaContentsSerializer < BaseSerializer
      include TripleEyeEffable::ResourceableSerializer
      include TypeableSerializer
      include UserDefineableSerializer

      index_attributes :uuid, :name
      show_attributes :uuid, :name
    end
  end
end