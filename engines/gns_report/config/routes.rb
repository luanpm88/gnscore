GnsReport::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/report" do
            resources :reports do
                collection do
                    get 'employees_schedule'
                    
                    get 'gantt_chart'
                    post 'gantt_chart_data'
                    
                    get 'project_report'
                    post 'project_report_data'
                    get 'project_report_xlsx'
                    
                    get 'employee_report'
                    post 'employee_report_data'
                    get 'employee_report_xlsx'
                    
                    get 'employee_working_hours_by_month'
                    post 'employee_working_hours_by_month_data'
                    get 'employee_working_hours_by_month_xlsx'
                    
                    get 'employee_working_hours_by_year'
                    post 'employee_working_hours_by_year_data'
                    get 'employee_working_hours_by_year_xlsx'
                    
                    get 'project_working_hours'
                    post 'project_working_hours_data'
                    get 'project_working_hours_xlsx'
                end
            end
        end
    end
end