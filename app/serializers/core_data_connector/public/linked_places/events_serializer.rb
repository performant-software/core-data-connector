module CoreDataConnector
  module Public
    module LinkedPlaces
      class EventsSerializer < Base
        # Includes
        include TypeableSerializer

        annotation_attributes(:id) { |event| "#{base_url}/events/#{event.uuid}" }
        annotation_attributes(:record_id) { |event| event.id }
        annotation_attributes(:title) { |event| event.name }
        annotation_attributes(:type) { 'Event' }
        annotation_attributes :uuid, :description, start_date: FuzzyDates::FuzzyDateSerializer,
                              end_date: FuzzyDates::FuzzyDateSerializer, user_defined: UserDefinedSerializer
      end
    end
  end
end