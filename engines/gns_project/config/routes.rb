GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'
                get ':id/tasks_infomation', to: 'projects#tasks', as: 'tasks'
                get ':id/tasks_attachment', to: 'projects#tasks_attachment', as: 'tasks_attachment'
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
        resources :tasks do
            collection do
                get 'select2'
                get ':id/attachments', to: 'tasks#attachments', as: 'attachments'
            end
        end
        resources :attachments do
            collection do
                get ':id/history', to: 'attachments#history', as: 'history'
            end
        end
    end
end
