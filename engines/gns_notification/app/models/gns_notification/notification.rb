module GnsNotification
  class Notification < ApplicationRecord
    
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
		
  end
end
