module CoreDataConnector
  class TaxonomiesController < ApplicationController
    # Includes
    include MergeableController
    include OwnableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :name
  end
end
