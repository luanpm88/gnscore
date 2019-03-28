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
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:first_name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_core_users.email) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |user|
        data[:results] << {id: user.id, text: user.full_name}
      end
      
      return data
    end
  end
end