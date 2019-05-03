GnsEmployee::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/employee" do
        resources :employees do
            collection do
                post 'list'
            end
        end
    end
end
