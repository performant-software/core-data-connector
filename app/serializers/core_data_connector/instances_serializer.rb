module CoreDataConnector
  class InstancesSerializer < BaseSerializer
    include OwnableSerializer
    include UserDefinedFields::FieldableSerializer

    index_attributes :id, :name
    show_attributes :id, :name, source_names: [:id, :name, :primary]
  end
end
