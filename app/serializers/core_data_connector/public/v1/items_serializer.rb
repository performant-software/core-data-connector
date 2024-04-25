module CoreDataConnector
  module Public
    module V1
      class ItemsSerializer < PublicSerializer
        include TypeableSerializer
        include UserDefineableSerializer

        index_attributes :uuid, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer
        show_attributes :uuid, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer,
                        web_identifiers: WebIdentifiersSerializer
      end
    end
  end
end