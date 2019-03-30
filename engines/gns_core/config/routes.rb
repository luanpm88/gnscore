GnsCore::Engine.routes.draw do
    devise_for :users,
        class_name: "GnsCore::User",
        module: :devise,
        controllers: {
            sessions: 'gns_core/users/sessions'
        },
        path_names: {
            sign_in: 'login',
            sign_out: 'logout'
        }
    root to: "backend/dashboard#index"
    
    namespace :backend, module: "backend", path: "backend/system" do
        resources :users do
            collection do
                get 'select2'
            end
        end
    end
end
