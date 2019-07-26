module GnsNotification
  class NotificationsUser < ApplicationRecord
    belongs_to :notification, class_name: 'GnsNotification::Notification'
    belongs_to :user, class_name: 'GnsCore::User'
    
    def self.read
      self.update_all(read: true)
    end
  end
end
