module GnsProject
  class ProjectEmployeeRole < ApplicationRecord
    belongs_to :project_employee, class_name: 'GnsProject::ProjectEmployee'
    belongs_to :role, class_name: 'GnsProject::Role'
  end
end
