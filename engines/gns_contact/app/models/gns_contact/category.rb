module GnsContact
  class Category < ApplicationRecord
    validates :name, :presence => true
    
    belongs_to :creator, class_name: 'GnsCore::User'
    belongs_to :parent, class_name: 'GnsContact::Category', optional: true    
    has_many :children, class_name: 'GnsContact::Category', foreign_key: "parent_id"
    has_many :categories_contacts, dependent: :restrict_with_error
    has_and_belongs_to_many :contacts, class_name: 'GnsContact::Contact'
    
    # get parent name
    def parent_name
      parent.present? ? parent.name : ''
    end
    
    def parent_full_name
      parent.present? ? parent.full_name : ''
    end
    
    # display name with parent
    def full_name
			names = [self.name]
			p = self.parent
			while !p.nil? do
				names << p.name
				p = p.parent
			end
			names.reverse.join(" > ")
		end
    
    # get active
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
      
      # filter by parent
      if params[:parent_id].present?
        query = query.where(parent_id: params[:parent_id])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_contact_categories.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
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
      
      query = self.get_active
      query = query.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_contact_categories.cache_search) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # where /params
      if params[:current_category_id].present?
        query = query.where.not(id: params[:current_category_id])
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |category|
        data[:results] << {id: category.id, text: category.full_name}
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
