GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'                
            end
        end
        resources :categories do
            collection do
                post 'list'
                get 'select2'
                get ':id/stages', to: 'categories#stages', as: 'stages'
            end
        end
        resources :stages
    end
end
