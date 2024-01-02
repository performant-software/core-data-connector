module CoreDataConnector
  class WorksSerializer < BaseSerializer
    include OwnableSerializer

    index_attributes :id, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer
    show_attributes :id, primary_name: SourceTitlesSerializer, source_titles: SourceTitlesSerializer
  end
end
