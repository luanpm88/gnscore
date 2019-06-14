GnsContact::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/contact" do
            resources :contacts do
                collection do
                    post 'list'
                    get 'select2'
                    put 'activate'
                    put 'deactivate'
                    get ':id/projects', to: 'contacts#projects', as: 'projects'
                    get ':id/subcontact_list', to: 'contacts#subcontact_list', as: 'subcontact_list'
                    put ':id/remove', to: 'contacts#remove_subcontact', as: 'remove_subcontact'
                    get 'subcontact_new'
                    post 'subcontact_create'
                    get ':id/subcontact_edit', to: 'contacts#subcontact_edit', as: 'subcontact_edit'
                    put 'subcontact_update'
                    get ':id/add_subcontact', to: 'contacts#add_subcontact', as: 'add_subcontact'
                    post ':id/add_subcontact', to: 'contacts#add_subcontact'
                end
            end
            resources :categories do
                collection do
                    post 'list'
                    get 'select2'
                    put 'activate'
                    put 'deactivate'
                end
            end
        end
    end
end
