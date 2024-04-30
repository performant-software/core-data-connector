# Admin CMS routes
module Admin
  def self.extended(router)
    router.instance_exec do
      resources :events

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
        get :export_variables, on: :member
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
    end
  end
end