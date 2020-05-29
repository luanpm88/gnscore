module GnsReport
  module Backend
    class ReportsController < GnsCore::Backend::BackendController
      
      def project_report
      end
      
      def project_report_data
        @from_date = params[:from_date].present? ? params[:from_date].to_date : nil
        @to_date = params[:to_date].present? ? params[:to_date].to_date : nil
        
        @customer = GnsContact::Contact.find(params[:customer_id]) if params[:customer_id].present?
        @projects = GnsProject::Project.search(params)#.includes(:tasks)
        
        #if @from_date.present?
        #  @projects = @projects.where('gns_project_tasks.start_date >= ?', @from_date)
        #end
        #
        #if @to_date.present?
        #  @projects = @projects.where('gns_project_tasks.end_date <= ?', @to_date)
        #end
        
        @pie_data = []
        legend_data = []
        series_data = []
        
        @projects.each do |project|
          legend_data << project.name
          series_data << {value: project.hours, name: project.name}
        end
        @pie_data << legend_data
        @pie_data << series_data
        @pie_data = @pie_data
        
        File.open("tmp/project_report_xlsx.yml", "w+") do |f|
          f.write({
            projects: @projects,
            projects_hours: @projects.hours
          }.to_yaml)
        end
        
        render layout: nil
      end
      
      def project_report_xlsx
        data = YAML.load_file("tmp/project_report_xlsx.yml")
        @projects = data[:projects]
        @projects_hours = data[:projects_hours]
        
        workbook = RubyXL::Parser.parse('templates/project_export_template.xlsx')
        worksheet = workbook[0]
        
        # Records
        sum = 0
        row_num = 4
        @projects.reverse.each do |project|
          worksheet.insert_row(4)
          worksheet[4][0].change_contents(project.code)
          worksheet[4][1].change_contents(project.name)
          worksheet[4][2].change_contents(project.hours)
          row_num += 1
        end
        worksheet[row_num][2].change_contents(@projects_hours)
        worksheet.delete_row(3)
        
        send_data workbook.stream.string,
          filename: "number-of-projects.xlsx",
          disposition: 'attachment'
      end
      
      def employee_report
      end
      
      def employee_report_data
        @from_date = params[:from_date].present? ? params[:from_date].to_date : nil
        @to_date = params[:to_date].present? ? params[:to_date].to_date : nil
        
        if params[:employee_id].present?
          @employee = GnsEmployee::Employee.find(params[:employee_id])
          @projects = GnsProject::Project.where(status: [
                        GnsProject::Project::STATUS_IN_PROGRESS,
                        GnsProject::Project::STATUS_DONE,
                      ])
                      .includes(:tasks)
                      .where(gns_project_tasks: {employee_id: @employee.id})
          
          if @from_date.present?
            @projects = @projects.where('gns_project_tasks.start_date >= ?', @from_date)
          end
          
          if @to_date.present?
            @projects = @projects.where('gns_project_tasks.end_date <= ?', @to_date)
          end
          
          @projects_legend_data = @projects.map {|p| p.name}.to_s
          @projects_series_data = @projects.map {|p| {value: p.hours, name: p.name}}.to_s
          
          @pie_data = []
          legend_data = []
          series_data = []
          
          @projects.each do |project|
            legend_data << project.name
            series_data << {value: project.hours(employee_id: @employee.id), name: project.name}
          end
          @pie_data << legend_data
          @pie_data << series_data
          @pie_data = @pie_data
          
          File.open("tmp/employee_report_xlsx.yml", "w+") do |f|
            f.write({
              from_date: @from_date,
              to_date: @to_date,
              projects: @projects,
              employee: @employee,
              projects_count: @projects.count,
              projects_hours: @projects.hours(employee_id: @employee.id)
            }.to_yaml)
          end
        end
        
        render layout: nil
      end
      
      def employee_report_xlsx
        data = YAML.load_file("tmp/employee_report_xlsx.yml")
        @from_date = data[:from_date]
        @to_date = data[:to_date]
        @projects = data[:projects]
        @employee = data[:employee]
        @projects_count = data[:projects_count]
        @projects_hours = data[:projects_hours]
        
        workbook = RubyXL::Parser.parse('templates/employee_export_template.xlsx')
        worksheet = workbook[0]
        
        worksheet[0][0].change_contents("BÁO CÁO DỰ ÁN THAM GIA CỦA NHÂN VIÊN")
        worksheet[1][0].change_contents("Thời gian: Từ #{@from_date.strftime('%d/%m/%Y')} - đến #{@to_date.strftime('%d/%m/%Y')}")
        worksheet[2][0].change_contents("Tên nhân viên: #{@employee.name}")
        # Records
        sum = 0
        row_num = 6
        @projects.reverse.each_with_index do |project,index|
          worksheet.insert_row(6)
          worksheet[6][0].change_contents(@projects_count - index)
          worksheet[6][1].change_contents(project.name)
          worksheet[6][2].change_contents(project.hours(employee_id: @employee.id))
          row_num += 1
        end
        worksheet[row_num][1].change_contents(@projects_count)
        worksheet[row_num][2].change_contents(@projects_hours)
        worksheet.delete_row(5)
        
        send_data workbook.stream.string,
          filename: "tinh-hinh-tham-gia-du-an-cua-nhan-vien.xlsx",
          disposition: 'attachment'
      end
      
      def gantt_chart
      end
      
      def gantt_chart_data
        @data = GnsEmployee::Employee.gantt_chart(params)
        
        render layout: nil
      end
      
      def employee_working_hours_by_month
      end
      
      def employee_working_hours_by_month_data
        render layout: nil
      end
      
      def employee_working_hours_by_month_xlsx
      end
      
      def employee_working_hours_by_year
      end
      
      def employee_working_hours_by_year_data
        render layout: nil
      end
      
      def employee_working_hours_by_year_xlsx
      end
      
      def project_working_hours
      end
      
      def project_working_hours_data
        @from_date = params[:from_date].present? ? params[:from_date].to_date : nil
        @to_date = params[:to_date].present? ? params[:to_date].to_date : nil
        
        if params[:project_id].present?
          @project = GnsProject::Project.find(params[:project_id])
          
          @tasks = @project.tasks
          
          if @from_date.present? and @to_date.present?
            @tasks = @tasks.where('gns_project_tasks.start_date <= ? and gns_project_tasks.end_date >= ?', @from_date, @from_date)
                    .or(@tasks.where('gns_project_tasks.end_date >= ? and gns_project_tasks.start_date <= ?', @to_date, @to_date))
                    .or(@tasks.where('gns_project_tasks.start_date >= ? and gns_project_tasks.end_date <= ?', @from_date, @to_date))
          end
          
          @employee_ids = @tasks.pluck(:employee_id).uniq
          @employees = GnsEmployee::Employee.where(id: @employee_ids)
          
          @employee_names = []
          @hour_data_series = []
          @total_hours = 0
          
          @employees.each do |employee|
            tasks = @tasks.where(employee_id: employee.id)
            
            total_hours_per_employee = 0
            number_of_days = 0
            hours_per_day = 0
            num_of_days_by_filter = 0
            tasks.each do |t|
              number_of_days = (t.start_date.to_date..t.end_date.to_date).to_a.size
              hours_per_day = (t.hours/number_of_days).round(3)
              
              if t.start_date <= @from_date
                first_date = @from_date
              else
                first_date = t.start_date
              end
              
              if t.end_date >= @to_date
                last_date = @to_date
              else
                last_date = t.end_date
              end
              
              # Number of task days by filter
              num_of_days_by_filter = (first_date.to_date..last_date.to_date).to_a.size
              
              # Number of task hours by filter
              num_of_hours_by_filter = hours_per_day*num_of_days_by_filter
              
              if num_of_days_by_filter == number_of_days
                num_of_hours_by_filter = t.hours
              end
              
              total_hours_per_employee += num_of_hours_by_filter
            end
            
            @employee_names << employee.name
            @hour_data_series  << {name: employee.name, value: total_hours_per_employee}
            @total_hours += total_hours_per_employee
          end
          
          @project_tasks = {
            filter_from_date: @from_date,
            filter_to_date: @to_date,
            project_name: @project.name,
            project_code: @project.code,
            employees_count: @employees.count,
            total_hours: @total_hours,
            employee_names: @employee_names,
            hour_data_series: @hour_data_series
          }
          
          File.open("tmp/user_#{current_user.id}_project_working_hours_report_xlsx.yml", "w+") do |f|
            f.write(@project_tasks.to_yaml)
          end
        end
        
        render layout: nil
      end
      
      def project_working_hours_xlsx
        data = YAML.load_file("tmp/user_#{current_user.id}_project_working_hours_report_xlsx.yml")
        
        @from_date = data[:filter_from_date]
        @to_date = data[:filter_to_date]
        @project_name = data[:project_name]
        @project_code = data[:project_code]
        @employees_count = data[:employees_count]
        @total_hours = data[:total_hours]
        @employee_names = data[:employee_names]
        @hour_data_series = data[:hour_data_series]
        
        logger.info @employees_count
        
        workbook = RubyXL::Parser.parse('templates/project_working_hours_export_template.xlsx')
        worksheet = workbook[0]
        
        worksheet[0][0].change_contents("BÁO CÁO THỜI GIAN THAM GIA DỰ ÁN CỦA NHÂN VIÊN")
        worksheet[1][0].change_contents("Thời gian: Từ #{@from_date.strftime('%d/%m/%Y')} - đến #{@to_date.strftime('%d/%m/%Y')}")
        worksheet[2][0].change_contents("Tên dự án: #{@project_name}")
        worksheet[3][0].change_contents("Mã dự án: #{@project_code}")
        # Records
        sum = 0
        row_num = 7
        @hour_data_series.reverse.each_with_index do |detail,index|
          worksheet.insert_row(7)
          worksheet[7][0].change_contents(@employees_count - index)
          worksheet[7][1].change_contents(detail[:name])
          worksheet[7][2].change_contents(detail[:value])
          row_num += 1
        end
        worksheet[row_num][1].change_contents(@employees_count)
        worksheet[row_num][2].change_contents(@total_hours)
        worksheet.delete_row(6)
        
        send_data workbook.stream.string,
          filename: "thoi-gian-tham-gia-du-an-cua-nhan-vien.xlsx",
          disposition: 'attachment'
      end
    end
  end
end
