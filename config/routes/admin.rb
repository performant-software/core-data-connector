# Admin CMS routes

concern :manifestable do
  post :create_manifests, on: :member
end

concern :mergeable do
  post :merge, on: :collection
end

resources :events, concerns: [:manifestable, :mergeable]

resources :instances, concerns: [:manifestable, :mergeable]

resources :items, concerns: [:manifestable, :mergeable] do
  get :analyze_import, on: :member
  post :import, on: :member
end

resources :jobs, only: [:destroy, :index]

resources :media_contents, concerns: [:manifestable, :mergeable] do
  post :upload, on: :collection
end

resources :organizations, concerns: [:manifestable, :mergeable]

resources :people, concerns: [:manifestable, :mergeable]

resources :places, concerns: [:manifestable, :mergeable]

resources :project_models do
  get :model_classes, on: :collection
end

resources :project_model_accesses, only: :index

resources :projects do
  post :analyze_import, on: :member
  post :clear, on: :member
  get :export_configuration, on: :member
  get :export_data, on: :member
  get :export_variables, on: :member
  post :import_analyze, on: :member
  post :import_configuration, on: :member
  post :import_data, on: :member
  get :map_library, on: :member
end

resources :record_merges, only: [:index, :destroy]

resources :relationships do
  post :upload, on: :collection
end

resources :taxonomies, concerns: [:manifestable, :mergeable]

resources :user_projects do
  post :invite, on: :member
end

resources :users do
  post :invite, on: :member
end

resources :web_authorities do
  get :find, on: :member
  get :search, on: :member
end

resources :web_identifiers

resources :works, concerns: [:manifestable, :mergeable]

