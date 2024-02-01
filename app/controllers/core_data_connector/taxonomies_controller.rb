module CoreDataConnector
  class TaxonomiesController < ApplicationController
    # Includes
    include OwnableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :name
  end
end
