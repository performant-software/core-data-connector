module CoreDataConnector
  class TaxonomiesSerializer < BaseSerializer
    include OwnableSerializer

    index_attributes :id, :name
    show_attributes :id, :name
  end
end
