GnsContact::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/contact" do
        resources :contacts do
            collection do
                post 'list'
            end
        end
    end
end