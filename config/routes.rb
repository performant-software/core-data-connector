CoreDataConnector::Engine.routes.draw do
  mount JwtAuth::Engine => '/auth'

  resources :instances
  resources :items
  resources :media_contents
  resources :names, only: :index
  resources :organizations
  resources :people
  resources :places
  resources :project_models do
    get :model_classes, on: :collection
  end
  resources :project_model_accesses, only: :index
  resources :projects do
    post :clear, on: :member
    get :export_configuration, on: :member
    post :import_configuration, on: :member
    post :import_data, on: :member
  end
  resources :relationships do
    post :upload, on: :collection
  end
  resources :taxonomies
  resources :user_projects
  resources :users
  resources :works

  namespace :public, only: [:index, :show] do
    resources :people, only: :show
    resources :places, only: :show do
      resources :media_contents, only: :index
      resources :organizations, only: :index
      resources :people, only: :index
      resources :places, only: :index
      resources :taxonomies, only: :index
    end
  end
end
