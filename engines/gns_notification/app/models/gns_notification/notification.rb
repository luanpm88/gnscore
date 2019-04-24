module GnsNotification
  class Notification < ApplicationRecord
    belongs_to :user, class_name: 'GnsCore::User'
    
    def self.add_new(phrase, user, data)
			GnsNotification::Notification::create(
				phrase: phrase,
				user: user.id,
				data: data
			)
		end

		def get_data
			ActiveSupport::JSON.decode(self.data).symbolize_keys
		end
		
		def user_name
      user.present? ? user.full_name : ''
    end
  end
end
