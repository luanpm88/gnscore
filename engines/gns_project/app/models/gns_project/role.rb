module GnsProject
  class Role < ApplicationRecord
    has_many :roles_permissions, class_name: 'GnsProject::RolesPermission'
    
    def get_status_label
      active? ? 'active' : 'inactive'
    end
    
    # Filters
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
					query = query.where('LOWER(gns_project_roles.name) LIKE ?', '%'+q.to_ascii.downcase+'%')
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
      
      query = self.order(:name)
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_roles.name) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |role|
        data[:results] << {id: role.id, text: role.name}
      end
      
      return data
    end
    
    # addPermission
    def add_permission(permission)
      roles_permission = self.roles_permissions.where(permission: permission).first
    
      if !roles_permission.present?
        roles_permission = self.roles_permissions.new(permission: permission)
        roles_permission.save
      end
    end
    
    # removePermission
    def remove_permission(permission)
      roles_permission = self.roles_permissions.where(permission: permission).first
      roles_permission.destroy if roles_permission.present?
    end
    
    # hasPermission
    def has_permission?(permission)
      return !self.roles_permissions.where(permission: permission).empty?
    end
    
    # permissionsCount
    def permissions_count
      return 0 if self.roles_permissions.empty?
      self.roles_permissions.count
    end
  end
end
