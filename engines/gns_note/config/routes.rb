GnsNote::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/note" do
            resources :personal_notes do
                collection do
                    post 'list'
                    put 'mark_as_done'
                    put 'mark_as_not_done_yet'
                end
            end
        end
    end
end
