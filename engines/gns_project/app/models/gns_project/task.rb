module GnsProject
  class Task < ApplicationRecord
    belongs_to :stage, class_name: 'GnsProject::Stage'
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :employee, class_name: 'GnsCore::User'
    has_many :attachments, dependent: :restrict_with_error
    
    validates :name, :start_date, :end_date,
              :stage_id, :project_id, :employee_id,
              :presence => true
    
    # get stage name
    def stage_name
      stage.present? ? stage.name : ''
    end
    
    # get employee name
    def employee_name
      employee.present? ? employee.full_name : ''
    end
    
    # count attachments
    def count_attachments
      self.attachments.count
    end
    
    # name with stage
    def name_with_stage
      "#{self.stage_name} / #{self.name}"
    end
    
    # get select2 records
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.includes(:stage).order("gns_project_stages.custom_order, gns_project_tasks.custom_order")
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_project_tasks.name) LIKE ?', '%'+params[:q].to_ascii.strip.downcase+'%')
      end
      
      # stage
      if params[:stage_id].present?
        query = query.where(stage_id: params[:stage_id])
      end
      
      # project
      if params[:project_id].present?
        query = query.where(project_id: params[:project_id])
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = query.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count >= per_page
      
      # render items
      query.each do |d|
        name = params[:include_stage_name].present? ? d.name_with_stage : d.name
        data[:results] << {id: d.id, text: name}
      end
      
      return data
    end
    
    # update custom_order
    def update_custom_order(current_task=nil)
      tasks_query = Task.where(project_id: self.project_id)
      max_order_num = tasks_query.maximum(:custom_order)
      
      if max_order_num == nil
        self.update_columns(custom_order: 1)
        
      elsif current_task.present?
        # tasks behind / update custom_order
        tasks_query.where("custom_order > ?", current_task.custom_order).update_all("custom_order=custom_order + 1")
        
        # self / update custom_order
        self.update_columns(custom_order: current_task.custom_order + 1)
      else
        self.update_columns(custom_order: max_order_num + 1)
      end
    end
    
    # class const
    STATUS_OPEN = 'open'
    STATUS_CLOSED = 'closed'
    
    # check status: true/false
    def is_open?
			return self.status == Task::STATUS_OPEN
		end
    
    def is_closed?
			return self.status == Task::STATUS_CLOSED
		end
    
    # set status
		def set_open
			update_attributes(status: GnsProject::Task::STATUS_OPEN)
		end
		
		def set_closed
			update_attributes(status: GnsProject::Task::STATUS_CLOSED)
		end
		
		# on/off finished
		def finish
			update_attributes(finished: true)
		end

    def unfinish
			update_attributes(finished: false)
		end
    
    def log(phrase, user, remark=nil)
      GnsProject::Log.add_new(self.project, phrase, self, user, remark)
    end
    
    # get logs list
    def logs
      query = self.project.logs
      query = query.where("data LIKE ?", "%GnsProject::Task%")
                .where("data LIKE ? AND data LIKE ?", "%name: id___value_before_type_cast: #{self.id}%", "%name: stage_id___value_before_type_cast: #{self.stage_id}%")
      # sap xep tu cu den moi
      query = query.order('created_at asc')
    end
    
    def get_latest_remark_log
      logs.last.remark
    end
    
    # check start date vs end date
    validate :check_start_date_vs_end_date
    def check_start_date_vs_end_date
      if start_date.present?
        if start_date < project.start_date
          errors.add(:start_date, :cannot_take_place_before_the_project_start_date)
        end
        
        if start_date > project.end_date
          errors.add(:start_date, :cannot_take_place_after_the_project_has_ended)
        end
      end
      
      if end_date.present?
        if end_date > project.end_date
          errors.add(:end_date, :must_take_place_before_the_project_end_date)
        end
      end
      
      if end_date.present? and start_date.present?  
        if end_date < start_date
          errors.add(:end_date, :cannot_take_place_before)
        end
      end
    end
    
    # get todo list
    def self.get_todo_list(user)
      # can cap nhat lai theo employee/user he thong
      GnsProject::Task.where(employee_id: user.id).where(status: GnsProject::Task::STATUS_OPEN)
    end
    
    # get todo list
    def self.get_wait_for_approval(user)
      # can cap nhat lai theo employee/user he thong
      GnsProject::Task.where(employee_id: user.id).where(status: GnsProject::Task::STATUS_OPEN).where(finished: true)
    end
  end
end
