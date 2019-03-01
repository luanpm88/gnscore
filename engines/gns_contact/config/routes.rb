GnsContact::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/contact" do
        resources :contacts do
            collection do
                post 'list'
                get 'select2'
                get ':id/projects', to: 'contacts#projects', as: 'projects'
            end
        end
    end
end
