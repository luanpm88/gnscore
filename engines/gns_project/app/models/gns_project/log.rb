module GnsProject
  class Log < ApplicationRecord
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :user, class_name: 'GnsCore::User'
    
    # get user name
    def user_name
      user.present? ? user.full_name : ''
    end
    
    # add log
    def self.add_new(project, phrase, object, user, remark=nil)
      log = project.logs.new
      log.phrase = phrase
      log.data = object.to_yaml
      log.class_name = object.class.name
      log.remark = remark
      log.user = user
      
      log.save
    end
    
    # data decode
    def get_data
      self.class_name.constantize.new
      YAML.load(self.data)
    end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by project
      if params[:project_id].present?
        query = query.where(project_id: params[:project_id])
      end
      
      if params[:log_type].present?
        query = query.where(class_name: params[:log_type])
      end
    
      if params[:task_id].present?
        query = query.where("data LIKE ? and data LIKE ?", "%GnsProject::Task%", "%name: id___value_before_type_cast: #{params[:task_id]}%")
      end
    
      if params[:attachment_id].present?
        query = query.where("data LIKE ? and data LIKE ?", "%GnsProject::Attachment%", "%name: id___value_before_type_cast: #{params[:attachment_id]}%")
      end
      
      # filter by from_date/to_date
      if params[:from_date].present?
        query = query.where("created_at >= ?", params[:from_date].to_date.beginning_of_day)
      end
      
      if params[:to_date].present?
        query = query.where("created_at <= ?", params[:to_date].to_date.end_of_day)
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
  end
end
