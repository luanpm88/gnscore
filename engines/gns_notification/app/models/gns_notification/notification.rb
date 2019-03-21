module GnsNotification
  class Notification < ApplicationRecord
    
    def self.add_new(phrase, user, data)
      return 'sssss'
			#GnsNotification::Notification::create(
			#	phrase: phrase,
			#	user: user.id,
			#	data: data
			#)
		end

		def get_data
			ActiveSupport::JSON.decode(self.data)
		end
		
  end
end
