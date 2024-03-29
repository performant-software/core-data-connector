module CoreDataConnector
  module Public
    class WorksSerializer < BaseSerializer
      include TypeableSerializer
      include UserDefineableSerializer

      index_attributes :uuid, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer
      show_attributes :uuid, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer
    end
  end
end