module CoreDataConnector
  module Public
    module V1
      class MediaContentsSerializer < PublicSerializer
        include TripleEyeEffable::ResourceableSerializer
        include TypeableSerializer
        include UserDefineableSerializer

        index_attributes :uuid, :name
        show_attributes :uuid, :name
      end
    end
  end
end