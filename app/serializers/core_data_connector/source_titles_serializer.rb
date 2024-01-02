module CoreDataConnector
  class SourceTitlesSerializer < BaseSerializer
    index_attributes :id, :primary, name: NamesSerializer
    show_attributes :id, :primary, name: NamesSerializer
  end
end
