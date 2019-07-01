module GnsArea
  class District < ApplicationRecord
    belongs_to :state, class_name: 'GnsArea::State'
    
    # update district cache search
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
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_area_districts.cache_search) LIKE ?', '%'+params[:q].to_ascii.downcase.strip+'%')
      end
      
      # country
      if params[:country_id].present?
        country = GnsArea::Country.find(params[:country_id])
        state_ids = country.states.map(&:id)
        query = query.where(state_id: state_ids)
      end
      
      # state
      if params[:state_id].present?
        query = query.where(state_id: params[:state_id])
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |d|
        data[:results] << {id: d.id, text: d.name}
      end
      
      return data
    end
    
  end
end
