CoreDataConnector::Engine.routes.draw do
  # JWT authentication
  mount JwtAuth::Engine, at: '/auth'

  # IIIF
  mount TripleEyeEffable::Engine, at: '/triple_eye_effable'

  # SSO authentication
  get 'auth/sso/callback', to: 'sso#login'

  # Admin API endpoints
  draw(:admin)

  # Public API endpoints
  draw(:v0)
  draw(:v1)

  # Reconciliation API endpoints
  draw(:reconcile)
end
