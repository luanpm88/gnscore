GnsContact::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/contact" do
        resources :contacts do
            collection do
                post 'list'
                get 'select2'
                get ':id/projects', to: 'contacts#projects', as: 'projects'
                get ':id/children', to: 'contacts#children', as: 'children'
                put ':id/remove', to: 'contacts#children', as: 'remove_child'
                get 'subcontact_new'
                post 'subcontact_create'
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
