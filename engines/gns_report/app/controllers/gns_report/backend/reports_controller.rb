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
        
        File.open("tmp/project_report_xlsx.yml", "w+") do |f|
          f.write({
            projects: @projects
          }.to_yaml)
        end
        
        render layout: nil
      end
      
      def project_report_xlsx
        data = YAML.load_file("tmp/project_report_xlsx.yml")
        @projects = data[:projects]
        
        workbook = RubyXL::Parser.parse('templates/project_export_template.xlsx')
        worksheet = workbook[0]
        
        # Records
        sum = 0
        row_num = 4
        @projects.each do |project|
          diff_date = (project.end_date.to_date - project.start_date.to_date).to_i + 1
          worksheet.insert_row(4)
          worksheet[4][0].change_contents(project.code)
          worksheet[4][1].change_contents(project.name)
          worksheet[4][2].change_contents(diff_date)
          row_num += 1
          sum += diff_date
        end
        worksheet[row_num][2].change_contents(sum)
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
          @projects = GnsProject::Project.where(status: GnsProject::Project::STATUS_IN_PROGRESS).includes(:tasks)
                      .where(gns_project_tasks: {employee_id: @employee.id})
          
          if @from_date.present?
            @projects = @projects.where('gns_project_tasks.start_date >= ?', @from_date)
          end
          
          if @to_date.present?
            @projects = @projects.where('gns_project_tasks.end_date <= ?', @to_date)
          end
          
          File.open("tmp/employee_report_xlsx.yml", "w+") do |f|
            f.write({
              from_date: @from_date,
              to_date: @to_date,
              projects: @projects,
              employee: @employee,
              projects_count: @projects.count,
              projects_number_of_days: @projects.number_of_days(employee_id: @employee.id)
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
        @projects_number_of_days = data[:projects_number_of_days]
        
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
          worksheet[6][2].change_contents(project.number_of_days(employee_id: @employee.id))
          row_num += 1
        end
        worksheet[row_num][1].change_contents(@projects_count)
        worksheet[row_num][2].change_contents(@projects_number_of_days)
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
    end
  end
end
