GnsContact::Engine.routes.draw do
    namespace :backend, module: "backend", path: "backend/contact" do
        resources :contacts
    end
end
