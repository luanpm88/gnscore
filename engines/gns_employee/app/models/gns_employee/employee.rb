module GnsEmployee
  class Employee < ApplicationRecord
    validates :name, presence: true
    validate :must_have_code
    validates_format_of :email, :allow_blank => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => " is invalid"
    
    belongs_to :creator, class_name: 'GnsCore::User'
    has_one :user, class_name: 'GnsCore::User', dependent: :restrict_with_error
    belongs_to :country, class_name: 'GnsArea::Country', optional: true
    belongs_to :state, class_name: 'GnsArea::State', optional: true
    belongs_to :district, class_name: 'GnsArea::District', optional: true
    has_many :project_employees, class_name: 'GnsProject::ProjectEmployee', dependent: :restrict_with_error
    has_many :project_employee_roles, class_name: 'GnsProject::ProjectEmployeeRole', through: :project_employees, dependent: :restrict_with_error
    has_many :projects, class_name: 'GnsProject::Project', foreign_key: :manager_id, dependent: :restrict_with_error
    has_many :tasks, class_name: 'GnsProject::Task', foreign_key: :employee_id, dependent: :restrict_with_error
    
    # class const
    GENDER_MALE = 'male'
    GENDER_FEMALE = 'female'
    
    # get gender
    def self.get_gender_options()
      [
        {text: I18n.t('male'),value: self::GENDER_MALE},
        {text: I18n.t('female'),value: self::GENDER_FEMALE}
      ]
    end
    
    # custom validate
    def must_have_code
      errors.add(:code, "can't be blank") if (id.present? and !code.present?)
    end
    
    # get coutry name
    def creator_name
      creator.present? ? creator.name : ''
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
        {text: I18n.t('seasonal'), value: self::LABOR_CONTRACT_TYPE_SEASONAL},
        {text: I18n.t('formal'), value: self::LABOR_CONTRACT_TYPE_FORMAL}
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
        data[:results] << {id: e.id, text: e.name}
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
    
    # activate
    def activate
			update_attributes(active: true)
		end
    
    # deactivate
    def deactivate
			update_attributes(active: false)
		end
    
    # Has project permission
    def has_project_permission?(project, permission)
      # Lấy quyền chỉnh sửa từng project ra trước xem có không
      # projet có quyền custom nào của user self không thì kiểm tra trước, có thì return luôn	
      #return true if project.project_employee.custom_permissions.include?(permission)

      # Không có chỉnh sửa quyền gì hết thì lấy mặc định (nếu không sửa)
      pers = self.project_employee_roles.includes(:project_employee).where(gns_project_project_employees: {project_id: project.id})
      
      return false if pers.empty?
      
      pers.each do |project_role|
        return project_role.role.has_permission?(permission)
      end
    end
    
    def project_permissions(project)
      project_employee = self.project_employees.where(project_id: project.id).first
      role_ids = project_employee.project_employee_roles.includes(:role).select("role_id")
      GnsProject::RolesPermission.where(role_id: role_ids).map(&:permission).uniq
    end
    
    def project_permission_count(project)
      self.project_permissions(project).count
    end
    
    def self.gantt_chart(params={})
      employees = GnsEmployee::Employee.get_active
      
      if params[:employee_ids].present?
        employees = employees.where(id: params[:employee_ids])
      end
      
      data = []
      first_row = []
      first_row << ''
      
      start_at = nil
      end_at = nil
      
      increment = nil
      anchor_date = Time.now
      anchor =  0
      anchor = params[:anchor].to_i if params[:anchor].present?
      
      if params[:chart_type].present?
        if params[:chart_type] == 'week'
          anchor_date = anchor_date + anchor.week
          
          start_at = anchor_date.beginning_of_week
          end_at = anchor_date.end_of_week
          increment = 1.day
        
          d = start_at.beginning_of_day
          while d <= end_at.end_of_day do
            first_row << {label: d.strftime('%d/%m/%Y'), date: d}
            d += increment
          end
        end
        
        if params[:chart_type] == 'month'
          anchor_date = anchor_date + anchor.month
          
          start_at = anchor_date.beginning_of_month
          end_at = anchor_date.end_of_month
          increment = 1.day
        
          d = start_at.beginning_of_day
          while d <= end_at.end_of_day do
            first_row << {label: d.strftime('%d.%m %Y'), date: d}
            d += increment
          end
        end
        
        if params[:chart_type] == 'year'
          anchor_date = anchor_date + anchor.year
          
          start_at = anchor_date.beginning_of_year
          end_at = anchor_date.end_of_year
          increment = 1.month
        
          d = start_at.beginning_of_day
          while d <= end_at.end_of_day do
            first_row << {label: d.strftime('%m/%Y'), date: d}
            d += increment
          end
        end
      end
      
      # first header
      data << first_row
      
      colors = ['#2ecaac', '#00796B', '#ff6252', '#2E7D32' , '#F4511E', '#00838F', '#AD1457', '#283593' , '#558B2F', '#607D8B', '#FFA726', '#54c6f9']
      
      employees.each do |employee|
        row = []
        row << employee.name
        
        tasks = employee.tasks.where('(start_date <= ? AND end_date >= ?) OR (end_date >= ? AND start_date <= ?)', end_at, start_at, start_at, end_at)
        
        tasks.each do |task|
          start_num = 1
          end_num = 1
          
          first_row[1..-1].each do |r|
            if params[:chart_type] == 'year'
              if task.start_date >= r[:date].end_of_month
                start_num += 1
                end_num += 1
              elsif r[:date].beginning_of_month <= task.end_date
                end_num += 1
              end
            else
              # @todo: Lỗi thanh <li> bị lùi về 1 ngày trước
              if task.start_date >= r[:date].end_of_day
                start_num += 1
                end_num += 1
              elsif r[:date].beginning_of_day <= task.end_date
                end_num += 1
              end
            end
          end
          
          row << {
            size: "#{start_num}/#{end_num}",
            color: colors[task.project_id%colors.count],
            label: task.name,
            name: task.project_name + ': ' + task.name  + ' (' + task.start_date.strftime('%d/%m/%Y') + ' - ' + task.end_date.strftime('%d/%m/%Y') + ')'
          }
        end
            
        data << row
      end
      
      return data
    end
  end
end
