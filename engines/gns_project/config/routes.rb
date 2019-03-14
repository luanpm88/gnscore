GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'
                get ':id/tasks', to: 'projects#tasks', as: 'tasks'
            end
        end
        resources :categories do
            collection do
                post 'list'
                get 'select2'
                get ':id/stages', to: 'categories#stages', as: 'stages'
            end
        end
        resources :stages do
            collection do
                get 'select2'
            end
        end
        resources :tasks
        resources :attachments
    end
end
