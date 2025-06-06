module CoreDataConnector
  class UsersController < ApplicationController
    # Search attributes
    search_attributes :name, :email

    # Preloads
    preloads user_projects: :project, only: :show
  end
end