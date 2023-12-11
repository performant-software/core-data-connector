module CoreDataConnector
  module Public
    class MediaContentsController < ApplicationController
      # Includes
      include OwnableController
      include RelateableController
      include UnauthenticateableController
      include UserDefinedFields::Queryable

      # Search attributes
      search_attributes :name
    end
  end
end