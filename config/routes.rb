CoreDataConnector::Engine.routes.draw do
  resources :organizations
  resources :people
  resources :places
  resources :projects
  resources :user_projects
  resources :users
end
