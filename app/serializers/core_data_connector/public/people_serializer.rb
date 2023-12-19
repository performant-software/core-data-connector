module CoreDataConnector
  module Public
    class PeopleSerializer < LinkedOpenDataSerializer
      index_attributes(:id) { |person| "#{ENV['HOSTNAME']}/public/people/#{person.uuid}" }
      index_attributes(:record_id) { |person| person.id }
      index_attributes(:title) { |person| person.full_name }
      index_attributes(:type){ 'Person' }
      index_attributes :biography, user_defined: UserDefinedSerializer
    end
  end
end