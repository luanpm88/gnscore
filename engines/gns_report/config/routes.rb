GnsReport::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/report" do
            resources :reports do
                collection do
                    get 'employees_schedule'
                    get 'gantt_chart'
                end
            end
        end
    end
end