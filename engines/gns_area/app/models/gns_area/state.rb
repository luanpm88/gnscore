module GnsArea
  class State < ApplicationRecord
    belongs_to :country, class_name: 'GnsArea::Country'
    has_many :districts, class_name: 'GnsArea::District', dependent: :restrict_with_error
    
    validates :name, :country_id, :presence => true
    
    # update state cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << name.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.all
      
      # keyword
      if params[:q].present?        
        query = query.where('LOWER(gns_area_states.cache_search) LIKE ?', '%'+params[:q].to_ascii.downcase.strip+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count > 0
      
      # render items
      query.each do |s|
        data[:results] << {id: s.id, text: s.name}
      end
      
      return data
    end
    
  end
end
