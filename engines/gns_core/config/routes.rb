GnsCore::Engine.routes.draw do
    devise_for :users,
        class_name: "GnsCore::User",
        module: :devise,
        controllers: {
            sessions: 'users/sessions'
        },
        path_names: {
            sign_in: 'login',
            sign_out: 'logout'
        }
    root to: "backend/dashboard#index"
end
