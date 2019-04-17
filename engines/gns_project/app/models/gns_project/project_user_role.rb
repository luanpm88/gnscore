module GnsProject
  class ProjectUserRole < ApplicationRecord
    belongs_to :project_user, class_name: 'GnsProject::ProjectUser'
    belongs_to :role, class_name: 'GnsProject::Role'
  end
end
