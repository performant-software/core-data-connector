module CoreDataConnector
  module Public
    module LinkedPlaces
      class PeopleSerializer < Base
        annotation_attributes(:id) { |person| "#{base_url}/people/#{person.uuid}" }
        annotation_attributes(:record_id) { |person| person.id }
        annotation_attributes(:title) { |person| person.full_name }
        annotation_attributes(:type){ 'Person' }
        annotation_attributes :uuid, :biography, user_defined: UserDefinedSerializer
      end
    end
  end
end