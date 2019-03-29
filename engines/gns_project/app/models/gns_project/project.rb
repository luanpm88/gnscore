module GnsProject
  class Project < ApplicationRecord
    belongs_to :creator, class_name: 'GnsCore::User'
    belongs_to :category, class_name: 'GnsProject::Category'
    belongs_to :customer, class_name: 'GnsContact::Contact'
    belongs_to :manager, class_name: 'GnsCore::User', foreign_key: :manager_id
    has_many :tasks, dependent: :restrict_with_error
    
    validates :code, :name, :priority, :start_date, :end_date,
              :category_id, :customer_id, :manager_id,
              :presence => true
    
    # get customer code
    def customer_code
      customer.present? ? customer.code : ''
    end
    
    # get customer name
    def customer_name
      customer.present? ? customer.full_name : ''
    end
    
    # get category name
    def category_name
      category.present? ? category.name : ''
    end
    
    # get manager name
    def manager_name
      manager.present? ? manager.full_name : ''
    end
    
    # get creator name
    def creator_name
      creator.present? ? creator.short_name : ''
    end
    
    # class const
    PRIORITY_HIGHT = 'high'
    PRIORITY_NORMAL = 'normal'
    PRIORITY_LOW = 'low'
    
    STATUS_NEW = 'new'
    STATUS_WAITING_APPROVE = 'waiting_approve'
    STATUS_PROGRESSING = 'progressing'
    STATUS_PAUSED = 'paused'
    STATUS_FINISHED = 'finished'
    STATUS_CANCELED = 'canceled'
    
    # get business type options
    def self.get_priority_options()
      [
        {text: 'High', value: self::PRIORITY_HIGHT},
        {text: 'Normal', value: self::PRIORITY_NORMAL},
        {text: 'Low', value: self::PRIORITY_LOW}
      ]
    end
    
    # update project cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << code.to_s.downcase.strip
			str << name.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by category
      if params[:category_id].present?
        query = query.where(category_id: params[:category_id])
      end
      
      # filter by customer
      if params[:customer_id].present?
        query = query.where(customer_id: params[:customer_id])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_project_projects.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
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
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_area_districts.cache_search) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
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
    
    def progress_percent
      all_tasks = self.tasks.count
      closed_tasks = self.tasks.where(status: GnsProject::Task::STATUS_CLOSED).count
      
      return (closed_tasks.to_f/all_tasks.to_f)*100
    end
    
    def open_tasks
      self.tasks.where(status: GnsProject::Task::STATUS_OPEN)
    end
  end
end
