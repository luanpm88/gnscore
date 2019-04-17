module GnsProject
  class ProjectUser < ApplicationRecord
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :user, class_name: 'GnsCore::User'
    has_many :project_user_roles, class_name: 'GnsProject::ProjectUserRole'
  end
end
