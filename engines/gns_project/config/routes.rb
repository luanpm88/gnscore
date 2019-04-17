GnsProject::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/project" do
        resources :projects do
            collection do
                post 'list'
                get ':id/authorization', to: 'projects#authorization', as: 'authorization'
                get ':id/authorization_list', to: 'projects#authorization_list', as: 'authorization_list'
                get ':id/tasks', to: 'projects#tasks', as: 'tasks'
                get ':id/tasks_list', to: 'projects#tasks_list', as: 'tasks_list'
                get ':id/attachments', to: 'projects#attachments', as: 'attachments'
                get ':id/attachments_list', to: 'projects#attachments_list', as: 'attachments_list'
                get ':id/download_attachments', to: 'projects#download_attachments', as: 'download_attachments'
                get ':id/logs', to: 'projects#logs', as: 'logs'
                post ':id/logs_list', to: 'projects#logs_list', as: 'logs_list'
                get 'add_authorization'
                post 'add_authorization'
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
                get ':id/attachments_list', to: 'tasks#attachments_list', as: 'attachments_list'
                get 'reopen'
                post 'reopen'
                get 'close'
                post 'close'
                get 'finish'
                post 'finish'
                get 'unfinish'
                post 'unfinish'
                get 'update_progress'
                post 'update_progress'
                get ':id/download_attachments', to: 'tasks#download_attachments', as: 'download_attachments'
            end
        end
        
        resources :attachments do
            collection do
                get 'select2'
                get ':id/logs', to: 'attachments#logs', as: 'logs'
                get ':id/logs_list', to: 'attachments#logs_list', as: 'logs_list'
                get ':id/download', to: 'attachments#download', as: 'download'
                get ':id/log_download/:attachment_log_id', to: 'attachments#log_download', as: 'log_download'
            end
        end
        
        resources :roles do
            collection do
                post 'list'
                get 'select2'
                get ':id/permissions', to: 'roles#permissions', as: 'permissions'
                post ':id/update_permissions', to: 'roles#update_permissions', as: 'update_permissions'
            end
        end
    end
end
