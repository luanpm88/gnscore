module GnsNotification
  class Notification < ApplicationRecord
    belongs_to :user, class_name: 'GnsCore::User'
    has_many :notifications_users, class_name: 'GnsNotification::NotificationsUser', dependent: :destroy
		
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
      
      return notification
    end
    
    def push_to_users(ability, object)      
			GnsCore::User.all.each do |user|
				if user.can?(ability, object) 
					self.notifications_users.create(
						user_id: user.id,
					)
        end
      end
    end
    
    # data decode
    def get_data
      self.class_name.constantize.new
      YAML.load(self.data)
    end
  end
end
