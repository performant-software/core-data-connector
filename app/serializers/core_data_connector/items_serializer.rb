module CoreDataConnector
  class ItemsSerializer < BaseSerializer
    include OwnableSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :name
    show_attributes :id, :name, :faircopy_cloud_id, source_names: [:id, :name, :primary]
  end
end
