module GnsCore
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable
    
    def add_notification(phrase, data)
			GnsNotification::Notification::create(
				phrase: phrase,
				user_id: self.id,
				data: data.to_json
			)
		end
    
    # display name for user
    def short_name
      str = []
      str << first_name.split(' ').last if first_name?
      str << last_name.split(' ').first if last_name?
      return str.join(" ")
    end
    
    def full_name
      str = []
      str << first_name if first_name?
      str << last_name if last_name?
      return str.join(" ")
    end
  end
end