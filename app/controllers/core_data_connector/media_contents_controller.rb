module CoreDataConnector
  class MediaContentsController < ApplicationController
    # Includes
    include OwnableController
    include TripleEyeEffable::ResourceableController
    include UserDefinedFields::Queryable

    # Search attributes
    search_attributes :name
  end
end