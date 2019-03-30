GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'
                get ':id/attachments', to: 'projects#attachments', as: 'attachments'
                get ':id/task_planning', to: 'projects#task_planning', as: 'task_planning'
                get ':id/task_attachment', to: 'projects#task_attachment', as: 'task_attachment'
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
                put 'reopen'
                put 'close'
                put 'finish'
                put 'unfinish'
                get ':id/attachments', to: 'tasks#attachments', as: 'attachments'
            end
        end
        resources :attachments do
            collection do
                get ':id/logs', to: 'attachments#logs', as: 'logs'
            end
        end
    end
end
