GnsEmployee::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/employee" do
        resources :employees do
            collection do
                post 'list'
                get 'select2'
                put 'activate'
                put 'deactivate'
                get ':id/account', to: 'employees#account_box', as: 'account_box'
            end
        end
    end
end
