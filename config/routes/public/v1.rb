module Public
  module V1
    def self.extended(router)
      router.instance_exec do

        namespace :public, only: [:index, :show] do
          namespace :v1 do
            resources :events, only: :show do
              resources :events, only: :index
              resources :instances, only: :index
              resources :items, only: :index
              resources :manifests
              resources :media_contents, only: :index
              resources :organizations, only: :index
              resources :people, only: :index
              resources :places, only: :index
              resources :taxonomies, only: :index
              resources :works, only: :index
            end

            resources :instances, only: :show do
              resources :events, only: :index
              resources :instances, only: :index
              resources :items, only: :index
              resources :manifests
              resources :media_contents, only: :index
              resources :organizations, only: :index
              resources :people, only: :index
              resources :places, only: :index
              resources :taxonomies, only: :index
              resources :works, only: :index
            end

            resources :items, only: :show do
              resources :events, only: :index
              resources :instances, only: :index
              resources :items, only: :index
              resources :manifests
              resources :media_contents, only: :index
              resources :organizations, only: :index
              resources :people, only: :index
              resources :places, only: :index
              resources :taxonomies, only: :index
              resources :works, only: :index
            end

            resources :places, only: :show do
              resources :events, only: :index
              resources :instances, only: :index
              resources :items, only: :index
              resources :manifests
              resources :media_contents, only: :index
              resources :organizations, only: :index
              resources :people, only: :index
              resources :places, only: :index
              resources :taxonomies, only: :index
              resources :works, only: :index
            end

            resources :projects, only: [] do
              get :descriptors, on: :member
            end

            resources :works, only: :show do
              resources :events, only: :index
              resources :instances, only: :index
              resources :items, only: :index
              resources :manifests
              resources :media_contents, only: :index
              resources :organizations, only: :index
              resources :people, only: :index
              resources :places, only: :index
              resources :taxonomies, only: :index
              resources :works, only: :index
            end
          end
        end

      end
    end
  end
end