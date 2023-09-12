module CoreDataConnector
  class OrganizationsSerializer < BaseSerializer
    # Includes
    include OwnableSerializer

    index_attributes :id, :name
    show_attributes :id, :name, :description, organization_names: [:id, :name, :primary]
  end
end