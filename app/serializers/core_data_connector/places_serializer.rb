module CoreDataConnector
  class PlacesSerializer < BaseSerializer
    index_attributes :id, :name
    show_attributes :id, place_names: [:id, :name, :primary]
  end
end
