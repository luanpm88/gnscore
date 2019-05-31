GnsReport::Engine.routes.draw do
  namespace :backend, module: "backend", path: "backend/report" do
        resources :reports do
            collection do
                get 'employees_schedule'
                get 'gantt_chart'
            end
        end
    end
end