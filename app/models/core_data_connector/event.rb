module CoreDataConnector
  class Event < ApplicationRecord
    # Includes
    include FuzzyDates::FuzzyDateable
    include Identifiable
    include Ownable
    include Relateable
    include UserDefinedFields::Fieldable

    # Fuzzy dates
    has_fuzzy_dates :start_date, :end_date
  end
end