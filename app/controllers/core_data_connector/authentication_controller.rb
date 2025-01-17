module CoreDataConnector
  class AuthenticationController < ApplicationController
    # No user authentication
    skip_before_action :authenticate_request
    before_action :bypass_authorization

    puts 'hi'

    def login
      render json: { motd: 'hello' }
    end
  end
end
