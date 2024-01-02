module CoreDataConnector
  class ItemsController < ApplicationController
    include NameableController
    include OwnableController
    include UserDefinedFields::Queryable

    preloads source_titles: :name

    joins primary_name: :name
  end
end
