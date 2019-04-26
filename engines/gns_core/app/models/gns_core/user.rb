module GnsCore
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable
    
    validates_format_of :email, :presence => true,
												:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
												:message => " is invalid (Eg. 'username@your-domain.com')"
    # validates :password, :length => { :minimum => 6, :maximum => 40 }, :confirmation => true
    
    has_and_belongs_to_many :roles, class_name: 'GnsCore::Role'
    has_many :project_users, class_name: 'GnsProject::ProjectUser'
    has_many :project_user_roles, class_name: 'GnsProject::ProjectUserRole', through: :project_users
    
    mount_uploader :avatar, GnsCore::AvatarUploader
    
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
    
    # update contact cache search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << first_name.to_s.downcase.strip
			str << last_name.to_s.downcase.strip
			str << email.to_s.downcase.strip

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by active
      #if params[:active].present?
      #  query = query.where(active: params[:active])
      #end
      
      # filter by roles
      if params[:role_ids].present?
        query = query.joins(:roles).where(gns_core_roles_users: {role_id: params[:role_ids]})
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_core_users.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
				end
			end

      return query
    end
    
    # search
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
      
      query = self.order(:first_name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_core_users.cache_search) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
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
    
    # has system permission
    def has_permission?(permission)      
      return !GnsCore::RolesPermission.where(role_id: self.roles.select(:id)).where(permission: permission).empty?
    end
    
    def has_project_permission?(project, permission)
      # Lấy quyền chỉnh sửa từng project ra trước xem có không
      # projet có quyền custom nào của user self không thì kiểm tra trước, có thì return luôn	
      #return true if project.project_user.custom_permissions.include?(permission)

      # Không có chỉnh sửa quyền gì hết thì lấy mặc định (nếu không sửa)
      purs = self.project_user_roles.includes(:project_user).where(gns_project_project_users: {project_id: project.id})
      
      return false if purs.empty?
      
      purs.each do |project_role|
        return project_role.role.has_permission?(permission)
      end
    end
    
    def project_permissions(project)
      project_user = self.project_users.where(project_id: project.id).first
      role_ids = project_user.project_user_roles.includes(:role).select("role_id")
      GnsProject::RolesPermission.where(role_id: role_ids).map(&:permission).uniq
    end
    
    def project_permission_count(project)
      self.project_permissions(project).count
    end
    
  end
end