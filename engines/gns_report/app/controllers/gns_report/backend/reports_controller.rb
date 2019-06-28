module GnsReport
  module Backend
    class ReportsController < GnsCore::Backend::BackendController
      
      def project_report
      end
      
      def project_report_data
        @customer = GnsContact::Contact.find(params[:customer_id]) if params[:customer_id].present?
        @projects = GnsProject::Project.search(params)
        
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
      
      
    end
  end
end
