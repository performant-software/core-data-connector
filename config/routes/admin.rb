# Admin CMS routes
module Admin
  def self.extended(router)
    router.instance_exec do
      resources :events do
        post :merge, on: :collection
      end

      resources :instances do
        post :merge, on: :collection
      end

      resources :items do
        get :analyze_import, on: :member
        post :import, on: :member
        post :merge, on: :collection
      end

      resources :media_contents do
        post :merge, on: :collection
      end

      resources :organizations do
        post :merge, on: :collection
      end

      resources :people do
        post :merge, on: :collection
      end

      resources :places do
        post :merge, on: :collection
      end

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

      resources :taxonomies do
        post :merge, on: :collection
      end

      resources :user_projects

      resources :users

      resources :web_authorities do
        get :find, on: :member
        get :search, on: :member
      end

      resources :web_identifiers

      resources :works do
        post :merge, on: :collection
      end
    end
  end
end
