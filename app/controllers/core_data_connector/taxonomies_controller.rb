module CoreDataConnector
  class TaxonomiesController < ApplicationController
    include OwnableController

    search_attributes :name
  end
end
