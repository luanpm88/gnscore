module GnsProject
  class Project < ApplicationRecord
    belongs_to :creator, class_name: 'GnsCore::User'
    belongs_to :manager, class_name: 'GnsEmployee::Employee', foreign_key: :manager_id
    belongs_to :customer, class_name: 'GnsContact::Contact'
    belongs_to :category, class_name: 'GnsProject::Category'
    has_many :tasks, class_name: 'GnsProject::Task', dependent: :restrict_with_error
    has_many :logs, class_name: 'GnsProject::Log'
    has_many :comments, class_name: "GnsProject::Comment"
    belongs_to :template, class_name: 'GnsProject::Template', optional: true
    has_many :project_employees, class_name: "GnsProject::ProjectEmployee", dependent: :destroy
    
    validates :code, uniqueness: true, presence: true
    validates :name, :priority, :category_id, :customer_id, :manager_id, presence: true
    
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
    
    # get template name
    def template_name
      template.present? ? template.name : ''
    end
    
    # get manager name
    def manager_name
      manager.present? ? manager.name : ''
    end
    
    # get creator name
    def creator_name
      creator.present? ? creator.short_name : ''
    end
    
    # count attachments
    def count_attachments
      return tasks.sum(&:count_attachments)
    end
    
    # class const
    PRIORITY_HIGHT = 'high'
    PRIORITY_NORMAL = 'normal'
    PRIORITY_LOW = 'low'
    
    STATUS_NEW = 'new'
    STATUS_PENDING = 'pending'
    STATUS_IN_PROGRESS = 'in_progress'
    STATUS_DONE = 'done'
    STATUS_FINISHED = 'finished'
    STATUS_CANCELED = 'canceled'
    
    # get business type options
    def self.get_priority_options()
      [
        {text: I18n.t('high'), value: self::PRIORITY_HIGHT},
        {text: I18n.t('normal'), value: self::PRIORITY_NORMAL},
        {text: I18n.t('low'), value: self::PRIORITY_LOW}
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
		
		# get active
    def self.get_active
			self.where(active: true)
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
      
      # filter by status
      if params[:status].present?
        query = query.where(status: params[:status])
      end
      
      # filter by active
      if params[:active].present?
        query = query.where(active: params[:active])
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
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_projects.cache_search) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
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
    
    # set status
    def set_new_for_status
			update_attributes(status: GnsProject::Project::STATUS_NEW)
		end
		
    def set_pending_for_status
			update_attributes(status: GnsProject::Project::STATUS_PENDING)
		end
		
    def set_in_progress_for_status
			update_attributes(status: GnsProject::Project::STATUS_IN_PROGRESS)
		end
		
		def set_finished_for_status
			update_attributes(status: GnsProject::Project::STATUS_DONE)
		end
		
		def set_canceled_for_status
			update_attributes(status: GnsProject::Project::STATUS_CANCELED)
		end
		
		# check if status
		def is_new?
      return status == GnsProject::Project::STATUS_NEW
    end
		
		def is_pending?
      return status == GnsProject::Project::STATUS_PENDING
    end
		
		def is_in_progress?
      return status == GnsProject::Project::STATUS_IN_PROGRESS
    end
		
		def is_finished?
      return status == GnsProject::Project::STATUS_DONE
    end
		
		def is_canceled?
      return status == GnsProject::Project::STATUS_CANCELED
    end
    
    # display progress percent
    def progress_percent
      result = 0
      
      if !self.tasks.empty?
        #all_tasks = self.tasks.count
        #closed_tasks = self.tasks.where(status: GnsProject::Task::STATUS_CLOSED).count
        #
        #result = (closed_tasks.to_f/all_tasks.to_f)*100
        result = self.tasks.sum(:progress)/self.tasks.count
      end
      
      return result
    end
    
    def open_tasks
      self.tasks.where(status: GnsProject::Task::STATUS_OPEN)
    end
    
    def get_tasks_not_closed
      self.tasks.where.not(status: GnsProject::Task::STATUS_CLOSED)
    end
    
    def log(phrase, user, remark=nil)
      GnsProject::Log.add_new(self, phrase, self, user, remark)
    end
    
    def self.get_waiting_projects
      GnsProject::Project.where('gns_project_projects.status IN (?)', [GnsProject::Project::STATUS_NEW, GnsProject::Project::STATUS_PENDING])
    end
    
    def self.get_nearly_expired_projects
      GnsProject::Project.where(status: GnsProject::Project::STATUS_IN_PROGRESS)
    end
    
    # add new user role
    def add_employee_role(employee_id, role_id)
      project_employee = GnsProject::ProjectEmployee.where(project_id: self.id, employee_id: employee_id).first
      if !project_employee.present?
        project_employee = GnsProject::ProjectEmployee.new(project_id: self.id, employee_id: employee_id)
        project_employee.save
      end

      project_employee_role = GnsProject::ProjectEmployeeRole.where(project_employee_id: project_employee.id, role_id: role_id).first
      if !project_employee_role.present?
        project_employee_role = GnsProject::ProjectEmployeeRole.new(project_employee_id: project_employee.id, role_id: role_id)
        project_employee_role.save
      end
    end
    
    # edit employee role
    def update_employee_roles(employee, role_ids)
      current_project_employee = employee.project_employees.where(project_id: self.id).first
      
      # Lay danh sach project_employee_role hien tai
      current_project_employee_roles = employee.project_employee_roles.includes(:project_employee).where(gns_project_project_employees: {project_id: self.id})
      
      # Xoa nhung project_employee_role can loai bo ra khoi danh sach hien tai
      current_project_employee_roles.where.not(role_id: role_ids).destroy_all
      
      role_ids.each do |rid|
        # Kiem tra da co project_employee_role chua, neu chua thi tao moi
        new_project_employee_role = GnsProject::ProjectEmployeeRole.where(project_employee_id: current_project_employee.id, role_id: rid).first
        if !new_project_employee_role.present?
          new_project_employee_role = GnsProject::ProjectEmployeeRole.new(project_employee_id: current_project_employee.id, role_id: rid)
          new_project_employee_role.save
        end
      end
    end
    
    # remove user role
    def remove_project_employee(project_employee)
      GnsProject::ProjectEmployee.find(project_employee.id).destroy
    end
    
    def get_employee_by_permissions(permissions=[])
      self.project_employees
          .joins("LEFT JOIN gns_project_project_employee_roles ON gns_project_project_employee_roles.project_employee_id = gns_project_project_employees.id")
          .joins("LEFT JOIN gns_project_roles ON gns_project_project_employee_roles .role_id = gns_project_roles.id")
          .joins("LEFT JOIN gns_project_roles_permissions ON gns_project_roles_permissions.role_id = gns_project_roles.id")
          .where(gns_project_roles_permissions: {permission: permissions})
    end
    
    # check start date vs end date
    validate :check_start_date_vs_end_date
    def check_start_date_vs_end_date
      if end_date.present? and start_date.present? and end_date < start_date
        errors.add(:end_date, :cannot_take_place_before)
      end
    end
    
    # apply template to project
    def apply_template_details_to_tasks
      if self.template.present?
        self.template.template_details.each do |td|
          task = self.tasks.new(
            name: td.task_description,
            stage_id: td.stage_id,
            status: GnsProject::Task::STATUS_OPEN,
            start_date: Time.now.beginning_of_day,
            end_date: Time.now.end_of_day,
            custom_order: td.custom_order,
            creator_id: self.creator_id
          )
          task.save
        end
      end
    end
    
    # get start date
    def get_start_date(options={})
      tasks = self.tasks
      
      if options[:employee_id].present?
        tasks = tasks.where(employee_id: options[:employee_id])
      end
      
      task = tasks.min_by(&:start_date)
      
      if task.present?
        return task.start_date
      else
        return nil
      end
    end
    
    # get end date
    def get_end_date(options={})
      tasks = self.tasks
      
      if options[:employee_id].present?
        tasks = tasks.where(employee_id: options[:employee_id])
      end
      
      task = tasks.max_by(&:end_date)
      
      if task.present?
        return task.end_date
      else
        return nil
      end
    end
    
    def number_of_days(options={})
      start_date = self.get_start_date(options)
      end_date = self.get_end_date(options)
      
      if end_date.present? and start_date.present?
        (end_date.to_date - start_date.to_date).to_i + 1
      else
        return 0
      end
    end
    
    def self.number_of_days(options={})
      sum { |p| p.number_of_days(options) }
    end
    
    def hours(options={})
      tasks = self.tasks
      
      if options[:employee_id].present?
        tasks = tasks.where(employee_id: options[:employee_id])
      end
      
      return tasks.sum(:hours)
    end
    
    def self.hours(options={})
      sum { |p| p.hours(options) }
    end
  end
end
