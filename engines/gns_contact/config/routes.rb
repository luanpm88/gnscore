GnsContact::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/contact" do
        resources :contacts do
            collection do
                post 'list'
                get 'select2'
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
            end
        end
    end
end
