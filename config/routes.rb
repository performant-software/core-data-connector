CoreDataConnector::Engine.routes.draw do
  resources :media_contents
  resources :organizations
  resources :people
  resources :places
  resources :project_models do
    get :model_classes, on: :collection
  end
  resources :project_model_accesses, only: :index
  resources :projects do
    post :import, on: :member
  end
  resources :relationships do
    post :upload, on: :collection
  end
  resources :taxonomies
  resources :user_projects
  resources :users
end
