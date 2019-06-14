GnsArea::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/area" do
            resources :countries do
                collection do
                    post 'list'
                    get 'select2'
                end
            end
            resources :states do
                collection do
                    post 'list'
                    get 'select2'
                end
            end
            resources :districts do
                collection do
                    post 'list'
                    get 'select2'
                end
            end
        end
    end
end
