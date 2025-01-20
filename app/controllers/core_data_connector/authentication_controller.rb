require 'typhoeus'

module CoreDataConnector
  class AuthenticationController < ApplicationController
    def login
      base_url = 'https://keycloak.archivengine.com/realms/core-data/protocol/openid-connect/token'

      form_data = {
        code: request.params['code'],
        client_id: ENV['SSO_CLIENT_ID'],
        client_secret: ENV['SSO_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: request.original_url.split('?')[0]
      }

      token_req = Typhoeus::Request.new(
        base_url,
        headers: {'Content-Type'=> "application/x-www-form-urlencoded"},
        method: :post,
        body: form_data
      )

      token_res = token_req.run

      puts token_res.body

      # backend authentication logic goes here

      # redirect_to ENV['SSO_REDIRECT_URL']
      render json: token_res.body
    end
  end
end
