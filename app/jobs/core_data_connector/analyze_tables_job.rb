module CoreDataConnector
  class AnalyzeTablesJob < ApplicationJob

    # Analyzes all foreign tables to keep statistics up to date
    def perform
      postgres = Postgres.new
      postgres.analyze_tables
    end

  end
end
