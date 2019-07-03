GnsReport::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/report" do
            resources :reports do
                collection do
                    get 'employees_schedule'
                    get 'gantt_chart'
                    
                    get 'project_report'
                    post 'project_report_data'
                    get 'project_report_xlsx'
                    
                    get 'employee_report'
                    post 'employee_report_data'
                    get 'employee_report_xlsx'
                end
            end
        end
    end
end