require 'typhoeus'
require 'jwt'
require 'jwt_auth/configuration'
require 'jwt_auth/json_web_token'

module CoreDataConnector
  class AuthenticationController < ApplicationController
    DEFAULT_TOKEN_EXPIRATION = 24

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
      parsed = JSON.parse(token_res.body)

      decoded = JWT.decode(parsed['access_token'], nil, false)[0]
      sso_metadata = HashWithIndifferentAccess.new decoded

      # todo: seems odd to have to reach into JwtAuth here, but
      #       we should stay consistent with email/password handling.
      #       maybe this logic should be moved into jwt-auth after all?
      user_serializer = JwtAuth.config.user_serializer.constantize

      user = User.find_by(sso_id: decoded['sub'])

      unless user
        user = User.create(
          email: decoded['email'],
          sso_id: decoded['sub'],
          name: join_name(decoded),
          # this randomly generated password is temporary for development
          # ideally the PW field would either be optional or get filled
          # with some sort of unique, secret, and persistent value from Keycloak
          # (I don't think the latter exists tbh)
          password: SecureRandom.hex
        )
      end

      user_json = user_serializer.new.render_show(user)

      # Making our own expiration time here means we're ignoring the time
      # set for the Keycloak token. That may or may not be okay. Keycloak
      # defaults to 5 minutes and seems to assume you'll be constantly
      # refreshing the token if you use theirs.
      expiration = expiration_date

      token = JwtAuth::JsonWebToken.encode(id: user.id, exp: expiration.to_i)

      # redirect_to ENV['SSO_REDIRECT_URL']
      render json: { token: token, exp: expiration.iso8601, user: user_json }, status: :ok
    end

    def expiration_date
      ENV.fetch('JWT_AUTH_EXPIRATION') { DEFAULT_TOKEN_EXPIRATION }.to_i.hours.from_now
    end

    def join_name(keycloak_user)
      [keycloak_user['first_name'], keycloak_user['last_name']].join(' ')
    end
  end
end
