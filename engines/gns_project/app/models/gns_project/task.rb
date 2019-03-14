module GnsProject
  class Task < ApplicationRecord
    belongs_to :stage
    belongs_to :project
    
    validates :name, :stage_id, :project_id, :presence => true
    
    # get stage name
    def stage_name
      stage.present? ? stage.name : ''
    end
  end
end
