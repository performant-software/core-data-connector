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
  resources :web_authorities do
    get :find, on: :member
    get :search, on: :member
  end
  resources :web_identifiers
  resources :works

  namespace :public, only: [:index, :show] do
    resources :instances do
      resources :instances, only: :index
      resources :items, only: :index
      resources :media_contents, only: :index
      resources :organizations, only: :index
      resources :people, only: :index
      resources :places, only: :index
      resources :taxonomies, only: :index
      resources :works, only: :index
    end

    resources :items do
      resources :instances, only: :index
      resources :items, only: :index
      resources :media_contents, only: :index
      resources :organizations, only: :index
      resources :people, only: :index
      resources :places, only: :index
      resources :taxonomies, only: :index
      resources :works, only: :index
    end

    resources :places, controller: 'linked_places/places' do
      resources :media_contents, only: :index, controller: 'linked_places/media_contents'
      resources :organizations, only: :index, controller: 'linked_places/organizations'
      resources :people, only: :index, controller: 'linked_places/people'
      resources :places, only: :index, controller: 'linked_places/places'
      resources :taxonomies, only: :index, controller: 'linked_places/taxonomies'
    end

    resources :works do
      resources :instances, only: :index
      resources :items, only: :index
      resources :media_contents, only: :index
      resources :organizations, only: :index
      resources :people, only: :index
      resources :places, only: :index
      resources :taxonomies, only: :index
      resources :works, only: :index
    end
  end
end
