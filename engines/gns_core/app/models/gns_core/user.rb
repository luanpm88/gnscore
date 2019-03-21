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
  end
end