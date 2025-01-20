require_relative 'routes/admin'
require_relative 'routes/public/v0'
require_relative 'routes/public/v1'

CoreDataConnector::Engine.routes.draw do
  extend Admin
  extend Public::V0
  extend Public::V1

  get 'auth/sso/callback', to: 'authentication#login'
end
