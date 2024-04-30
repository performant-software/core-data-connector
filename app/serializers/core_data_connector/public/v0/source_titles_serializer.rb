module CoreDataConnector
  module Public
    module V0
      class SourceTitlesSerializer < BaseSerializer
        index_attributes :id, :primary, name: NamesSerializer
        show_attributes :id, :primary, name: NamesSerializer
      end
    end
  end
end
