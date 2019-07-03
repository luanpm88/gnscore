module GnsContact
  class Contact < ApplicationRecord
    #validates :code, uniqueness: true, presence: true#, allow_blank: true
    validates :full_name, :contact_type, presence: true
    validates_format_of :email, :allow_blank => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => " is invalid"
    
    belongs_to :creator, class_name: 'GnsCore::User'
    belongs_to :country, class_name: 'GnsArea::Country', optional: true
    belongs_to :state, class_name: 'GnsArea::State', optional: true
    belongs_to :district, class_name: 'GnsArea::District', optional: true
    has_many :projects, class_name: 'GnsProject::Project', foreign_key: :customer_id, dependent: :restrict_with_error # Prevent deleting record being used
    
    has_and_belongs_to_many :categories, class_name: 'GnsContact::Category'
    validates :categories, presence: true
    
    has_many :parent_contacts
    has_many :children_contacts, class_name: 'GnsContact::ParentContact', foreign_key: :parent_id
    has_many :parent, class_name: 'GnsContact::Contact', through: :parent_contacts
    has_many :children, class_name: 'GnsContact::Contact', through: :children_contacts
    
    validate :code_required
    def code_required
      if !code.present? and contact_type == GnsContact::Contact::TYPE_COMPANY
        errors.add(:code, :message)
      end
    end
    
    # get name
    def name
      self.full_name
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
    
    def get_full_address
      str = []
      str << address if address?
      str << district_name if district_name.present?
      str << state_name if state_name.present?
      str << country_name if country_name.present?
      return str.join(", ")
    end
    
    def get_status_label
      active? ? 'active' : 'inactive'
    end
    
    # getActive
    def self.get_active
			self.where(active: true)
		end
    
    # class const
    TYPE_PERSON = 'person'
    TYPE_COMPANY = 'company'
    
    # get business type options
    def self.get_type_options()
      [
        {text: I18n.t('company'), value: self::TYPE_COMPANY},
        {text: I18n.t('person'), value: self::TYPE_PERSON},
      ]
    end
    
    # update contact cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << code.to_s.downcase.strip
			str << full_name.to_s.downcase.strip
			str << foreign_name.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by active
      if params[:active].present?
        query = query.where(active: params[:active])
      end
      
      # filter by active
      if params[:category_ids].present?
        query = query.joins(:categories).where(gns_contact_categories_contacts: {category_id: params[:category_ids]})
      end
      
      # filter by bussiness partner type
      if params[:contact_type].present?
        query = query.where(contact_type: params[:contact_type])
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
					query = query.where('LOWER(gns_contact_contacts.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
				end
			end

      return query
    end
    
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
      query = query.order(:full_name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_contact_contacts.cache_search) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # where /params
      if params[:current_contact_id].present?
        query = query.where.not(id: params[:current_contact_id])
      end
      
      # exclude self id and his children id
      if params[:exclude_self_children_of_contact_id].present?
        contact = self.find(params[:exclude_self_children_of_contact_id])
        no_ids = [contact.id] + contact.children.map(&:id)
        query = query.where.not(id: no_ids)
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |c|
        data[:results] << {id: c.id, text: c.name}
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
