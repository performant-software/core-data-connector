CoreDataConnector::Engine.routes.draw do
  mount JwtAuth::Engine => '/auth'

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
