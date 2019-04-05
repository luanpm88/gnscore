GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'
                get ':id/attachments', to: 'projects#attachments', as: 'attachments'
                get ':id/task_planning', to: 'projects#task_planning', as: 'task_planning'
                get ':id/task_attachment', to: 'projects#task_attachment', as: 'task_attachment'
                get ':id/download_attachments', to: 'projects#download_attachments', as: 'download_attachments'
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
                get 'reopen'
                post 'reopen'
                get 'close'
                post 'close'
                get 'finish'
                post 'finish'
                get 'unfinish'
                post 'unfinish'
            end
        end
        resources :attachments do
            collection do
                get ':id/logs', to: 'attachments#logs', as: 'logs'
                get ':id/download', to: 'attachments#download', as: 'download'
            end
        end
    end
end
