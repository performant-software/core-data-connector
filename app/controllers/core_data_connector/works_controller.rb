module CoreDataConnector
  class WorksController < ApplicationController
    # Includes
    include MergeableController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Preloads
    preloads source_titles: :name

    # Joins
    joins primary_name: :name
  end
end
