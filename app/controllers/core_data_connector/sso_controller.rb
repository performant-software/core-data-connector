require 'typhoeus'
require 'jwt'
require 'jwt_auth/configuration'
require 'jwt_auth/json_web_token'
require 'uri'

module CoreDataConnector
  class SsoController < ApplicationController
    DEFAULT_TOKEN_EXPIRATION = 24

    # No user authentication
    skip_before_action :authenticate_request

    def login
      base_url = ENV['SSO_TOKEN_URL']

      form_data = {
        code: request.params['code'],
        client_id: ENV['SSO_CLIENT_ID'],
        client_secret: ENV['SSO_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: ENV['REACT_APP_SSO_REDIRECT_URI']
      }

      token_req = Typhoeus::Request.new(
        base_url,
        headers: {'Content-Type'=> "application/x-www-form-urlencoded"},
        method: :post,
        body: form_data
      )

      token_res = token_req.run
      parsed = JSON.parse(token_res.body)

      decoded = JWT.decode(parsed['access_token'], nil, false)[0]

      sso_metadata = HashWithIndifferentAccess.new decoded

      sso_user = find_sso_user(sso_metadata)

      unless sso_user
        render json: { error: I18n.t('errors.users.not_found') }, status: :unauthorized
      end
      
      user_json = UsersSerializer.new.render_show(sso_user)

      # Making our own expiration time here means we're ignoring the time
      # set for the Keycloak token. Keycloak defaults to 5 minutes and seems
      # to assume you'll be constantly refreshing the token if you use theirs.
      expiration = expiration_date

      token = JwtAuth::JsonWebToken.encode(id: sso_user.id, exp: expiration.to_i)
      data = { token: token, exp: expiration.iso8601, user: user_json }

      redirect_to "#{ENV['SSO_REDIRECT_URL']}?token=#{Base64.encode64(data.to_json)}"
    end

    def expiration_date
      ENV.fetch('JWT_AUTH_EXPIRATION') { DEFAULT_TOKEN_EXPIRATION }.to_i.hours.from_now
    end

    def find_sso_user(sso_metadata)
      existing_sso_user = User.find_by(sso_id: sso_metadata['sub'])

      # User has signed in with SSO before
      if existing_sso_user
        return existing_sso_user
      end

      existing_email_user = User.find_by(email: sso_metadata['email'])

      # User has not previously signed in with SSO, and needs
      # to be transformed into an SSO user.
      if existing_email_user
        existing_email_user.sso_id = sso_metadata['sub']

        return existing_email_user
      end

      nil
    end
  end
end
