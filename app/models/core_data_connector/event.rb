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
    include Reconcile::Event
    include Relateable
    include Search::Event
    include UserDefinedFields::Fieldable

    # Fuzzy dates
    has_fuzzy_dates :start_date, :end_date

    # User defined fields parent
    resolve_defineable -> (event) { event.project_model }
  end
end