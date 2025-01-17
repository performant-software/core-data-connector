require_relative 'routes/admin'
require_relative 'routes/public/v0'
require_relative 'routes/public/v1'

CoreDataConnector::Engine.routes.draw do
  extend Admin
  extend Public::V0
  extend Public::V1

  post 'auth/login', to: 'authentication#login'
  post 'auth/sso', to: 'authentication#sso'
end
