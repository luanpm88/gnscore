module GnsProject
  class Log < ApplicationRecord
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :user, class_name: 'GnsCore::User'
    
    def self.log(phrase, object, user, remark=nil)
      log = self.new
      log.phrase = phrase
      log.data = object.to_yaml
      log.class_name = object.class.name
      log.remark = remark
      log.project = object.project
      log.user = user
      
      log.save
    end
  
    def get_data
      YAML.load(self.data)
    end
  end
end
