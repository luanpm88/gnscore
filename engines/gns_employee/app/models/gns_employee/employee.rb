module GnsEmployee
  class Employee < ApplicationRecord
    validates :name, presence: true
    validate :must_have_code
    
    belongs_to :country, class_name: 'GnsArea::Country', optional: true
    belongs_to :state, class_name: 'GnsArea::State', optional: true
    belongs_to :district, class_name: 'GnsArea::District', optional: true
    
    # custom validate
    def must_have_code
      errors.add(:code, "can't be blank") if (id.present? and !code.present?)
    end
    
    # get coutry name
    def country_name
      country.present? ? country.name : ''
    end
    
    # get state name
    def state_name
      state.present? ? state.name : ''
    end
    
    # get district name
    def district_name
      district.present? ? district.name : ''
    end
    
    # get all active
    def self.get_active
			self.where(active: true)
		end
    
    # class const
    LABOR_CONTRACT_TYPE_SEASONAL = 'seasonal'
    LABOR_CONTRACT_TYPE_FORMAL = 'formal'
    
    # get business type options
    def self.get_labor_contract_type_options()
      [
        {text: 'Seasonal Contract', value: self::LABOR_CONTRACT_TYPE_SEASONAL},
        {text: 'Formal  Contract', value: self::LABOR_CONTRACT_TYPE_FORMAL}
      ]
    end
    
    # update cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << code.to_s.downcase.strip
			str << name.to_s.downcase.strip
			str << email.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by active
      if params[:active].present?
        query = query.where(active: params[:active])
      end
      
      # filter by labor contract type
      if params[:labor_contract_type].present?
        query = query.where(labor_contract_type: params[:labor_contract_type])
      end
      
      # filter by country_id
      if params[:country_id].present?
        query = query.where(country_id: params[:country_id])
      end
      
      # filter by state_id
      if params[:state_id].present?
        query = query.where(state_id: params[:state_id])
      end
      
      # filter by district_id
      if params[:district_id].present?
        query = query.where(district_id: params[:district_id])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_employee_employees.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
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
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.get_active
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_employee_employees.cache_search) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |e|
        data[:results] << {id: e.ie, text: e.name}
      end
      
      return data
    end
    
    # force generate code
    after_create :generate_code
    def generate_code
      
      query = GnsEmployee::Employee.all
      
      num = query.where('created_at <= ?', self.created_at).count

      self.code = "E#{num.to_s.rjust(4, '0')}"
      self.save
		end
  end
end
