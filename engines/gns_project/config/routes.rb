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
            end
        end
    end
end
