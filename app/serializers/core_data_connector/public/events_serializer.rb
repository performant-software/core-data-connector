module CoreDataConnector
  module Public
    class EventsSerializer < BaseSerializer
      include TypeableSerializer
      include UserDefineableSerializer

      index_attributes :uuid, :name, :description, start_date: FuzzyDates::FuzzyDateSerializer, end_date: FuzzyDates::FuzzyDateSerializer
      show_attributes :uuid, :name, :description, start_date: FuzzyDates::FuzzyDateSerializer, end_date: FuzzyDates::FuzzyDateSerializer
    end
  end
end