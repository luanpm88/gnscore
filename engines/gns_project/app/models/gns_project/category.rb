module GnsProject
  class Category < ApplicationRecord
    belongs_to :creator, class_name: 'GnsCore::User'
    has_many :projects, dependent: :restrict_with_error # Prevent deleting record being used
    has_many :stages, dependent: :restrict_with_error
    
    validates :name, :presence => true
    
    # get creator name
    def creator_name
      creator.present? ? creator.short_name : ''
    end
    
    # get status
    def get_status_label
      active? ? 'active' : 'inactive'
    end
    
    # getActive
    def self.get_active
			self.where(active: true)
		end
    
    # update category cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << name.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by active
      if params[:active].present?
        query = query.where(active: params[:active])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_project_categories.cache_search) LIKE ?', '%'+q.to_ascii.strip.downcase+'%')
				end
			end

      return query
    end
    
    # searchs
    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_categories.cache_search) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
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
    
    # activate
    def activate
			update_attributes(active: true)
		end
    
    # deactivate
    def deactivate
			update_attributes(active: false)
		end
  end
end
