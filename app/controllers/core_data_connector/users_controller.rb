module CoreDataConnector
  class UsersController < ApplicationController
    search_attributes :name, :email
  end
end