# Reconciliation API routes

namespace :reconcile do
  get 'projects/:id', to: 'projects#show'
  post 'projects/:id', to: 'projects#show'
end