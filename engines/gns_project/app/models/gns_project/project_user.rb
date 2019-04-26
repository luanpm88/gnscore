module GnsProject
  class ProjectUser < ApplicationRecord
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :user, class_name: 'GnsCore::User'
    has_many :project_user_roles, class_name: 'GnsProject::ProjectUserRole', dependent: :destroy
    
    # get project name
    def project_name
      project.present? ? project.name : ''
    end
    
    # get user name
    def user_name
      user.present? ? user.full_name : ''
    end
    
    # add log
    def log(phrase, user, remark=nil)
      GnsProject::Log.add_new(self.project, phrase, self, user, remark)
    end
  end
end
