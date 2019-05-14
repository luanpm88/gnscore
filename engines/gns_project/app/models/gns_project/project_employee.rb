module GnsProject
  class ProjectEmployee < ApplicationRecord
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :employee, class_name: 'GnsEmployee::Employee'
    has_many :project_employee_roles, class_name: 'GnsProject::ProjectEmployeeRole', dependent: :destroy
    
    # get project name
    def project_name
      project.present? ? project.name : ''
    end
    
    # get employee name
    def employee_name
      employee.present? ? employee.name : ''
    end
    
    # add log
    def log(phrase, user, remark=nil)
      GnsProject::Log.add_new(self.project, phrase, self, user, remark)
    end
  end
end
