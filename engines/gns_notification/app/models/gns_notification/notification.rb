module GnsNotification
  class Notification < ApplicationRecord
    belongs_to :user, class_name: 'GnsCore::User'
		
		# get user name
    def user_name
      user.present? ? user.name : ''
    end
    
    # add notification
    def self.add_new(phrase, object, user, remark=nil)
      notification = GnsNotification::Notification.new
      notification.phrase = phrase
      notification.data = object.to_yaml
      notification.class_name = object.class.name
      notification.user = user
      #notification.remark = remark
      
      notification.save
    end
    
    # data decode
    def get_data
      self.class_name.constantize.new
      YAML.load(self.data)
    end
  end
end
