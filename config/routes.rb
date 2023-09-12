CoreDataConnector::Engine.routes.draw do
  resources :people
  resources :places
  resources :projects
  resources :user_projects
  resources :users
end
