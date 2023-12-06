module CoreDataConnector
  module Public
    class PeopleSerializer < CoreDataConnector::PeopleSerializer
      include PublicSerializer
    end
  end
end