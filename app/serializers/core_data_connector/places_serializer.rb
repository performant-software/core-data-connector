module CoreDataConnector
  class PlacesSerializer < BaseSerializer
    # Includes
    include OwnableSerializer

    index_attributes :id, :name
    show_attributes :id, :name, place_names: [:id, :name, :primary]
  end
end
