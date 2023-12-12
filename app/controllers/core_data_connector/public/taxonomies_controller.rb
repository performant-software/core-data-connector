module CoreDataConnector
  module Public
    class TaxonomiesController < ApplicationController
      # Includes
      include OwnableController
      include RelateableController
      include UnauthenticateableController

      # Search attributes
      search_attributes :name
    end
  end
end