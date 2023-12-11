module CoreDataConnector
  module Public
    class PlacesSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      index_attributes :title, user_defined: UserDefinedSerializer

      show_attributes(:@id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      show_attributes(:type) { 'Feature' }
      show_attributes(:properties) { |place| { ccode: [], title: place.name } }
      show_attributes(:geometry) { |place| place.place_geometry&.to_geojson }
      show_attributes(:names) { |place| place.place_names.map{ |name| { toponym: name.name } } }
      show_attributes user_defined: UserDefinedSerializer

      target_attributes(:id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      target_attributes(:title) { |place| place.primary_name&.name }
    end
  end
end