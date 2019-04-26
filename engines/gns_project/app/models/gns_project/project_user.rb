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
  end
end
