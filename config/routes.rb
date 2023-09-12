CoreDataConnector::Engine.routes.draw do
  resources :organizations
  resources :people
  resources :places
  resources :project_models do
    get :model_classes, on: :collection
  end
  resources :projects
  resources :user_projects
  resources :users
end
