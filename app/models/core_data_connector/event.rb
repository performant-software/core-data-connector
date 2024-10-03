module CoreDataConnector
  class Event < ApplicationRecord
    # Includes
    include Export::Event
    include FuzzyDates::FuzzyDateable
    include Identifiable
    include ImportAnalyze::Event
    include Manifestable
    include Mergeable
    include Ownable
    include Relateable
    include Search::Event
    include UserDefinedFields::Fieldable

    # Fuzzy dates
    has_fuzzy_dates :start_date, :end_date
  end
end