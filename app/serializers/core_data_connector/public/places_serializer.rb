module CoreDataConnector
  module Public
    class PlacesSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      index_attributes(:record_id) { |place| place.id }
      index_attributes(:title) { |place| place.name }
      index_attributes(:type) { 'Place' }
      index_attributes(:geometry) { |place| place.place_geometry&.to_geojson }
      index_attributes user_defined: UserDefinedSerializer

      show_attributes(:@id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      show_attributes(:record_id) { |place| place.id }
      show_attributes(:type) { 'Place' }
      show_attributes(:properties) { |place| { ccode: [], title: place.name } }
      show_attributes(:geometry) { |place| place.place_geometry&.to_geojson }
      show_attributes(:names) { |place| place.place_names.map{ |name| { toponym: name.name } } }
      show_attributes user_defined: UserDefinedSerializer

      target_attributes(:id) { |place| "#{ENV['HOSTNAME']}/public/places/#{place.uuid}" }
      target_attributes(:record_id) { |place| place.id }
      target_attributes(:name) { |place| place.primary_name&.name }
      target_attributes(:type) { 'Place' }
    end
  end
end