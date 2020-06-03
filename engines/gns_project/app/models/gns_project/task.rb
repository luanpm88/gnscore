module GnsProject
  class Task < ApplicationRecord
    belongs_to :creator, class_name: 'GnsCore::User'
    belongs_to :stage, class_name: 'GnsProject::Stage'
    belongs_to :project, class_name: 'GnsProject::Project'
    belongs_to :employee, class_name: 'GnsEmployee::Employee', optional: true
    has_many :attachments, dependent: :restrict_with_error
    
    validates :name, :start_date, :end_date,
              :stage_id, :project_id,
              :presence => true
    
    # get creator
    def creator_name
      creator.present? ? creator.name : ''
    end
    # get stage name
    def stage_name
      stage.present? ? stage.name : ''
    end
    
    # get project name
    def project_name
      project.present? ? project.name : ''
    end
    
    # get project code
    def project_code
      project.present? ? project.code : ''
    end
    
    # get employee name
    def employee_name
      employee.present? ? employee.name : ''
    end
    
    # get employee email
    def employee_email
      if employee.present?
        employee.email.present? ? employee.email : ''
      else
        ''
      end
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
      if logs.empty?
        return nil
      else
        logs.last.remark
      end
    end
    
    # check start date vs end date
    #validate :check_start_date_vs_end_date
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
    
    # get all tasks
    def self.all_tasks(params={})
      query = GnsProject::Task.all
      
      if params[:status].present?
        query = query.where(status: params[:status])
      end
      
      if params[:finished].present?
        query = query.where(finished: params[:finished])
      end
      
      return query
    end
    
    def self.assigned_all?
      return self.all_tasks.where(employee_id: nil).empty?
    end
    
    def self.finished_of_all_rate
      all_count = self.all_tasks.count
      finished_count = self.all_tasks(finished: 'true').count
      return (finished_count.to_f/all_count.to_f)*100
    end
    
    # count/tasks are open
    def self.open_of_all_rate
      all_count = self.all_tasks.count
      open_count = self.all_tasks(status: GnsProject::Task::STATUS_OPEN).count
      
      return 0 if all_count == 0
      return (open_count.to_f/all_count.to_f)*100
    end
    
    # count/tasks are open
    def self.closed_of_all_rate
      all_count = self.all_tasks.count
      closed_count = self.all_tasks(status: GnsProject::Task::STATUS_CLOSED).count
      
      return 0 if all_count == 0
      return (closed_count.to_f/all_count.to_f)*100
    end
    
    # get todo list
    def self.get_todo_list(user={})
      # can cap nhat lai theo employee/user he thong
      if user.present?
        GnsProject::Task.where(employee_id: user.id).where(status: GnsProject::Task::STATUS_OPEN)
      else
        return GnsProject::Task.where(id: -1)
      end
    end
    
    # get wait for approval
    def self.get_wait_for_approval(user={})
      # can cap nhat lai theo employee/user he thong
      GnsProject::Task.where(status: GnsProject::Task::STATUS_OPEN).where(finished: true)
    end
    
    # working hours by date
    def self.working_hours_by_date(fromdate, todate)
      from_date = fromdate.to_date
      to_date = todate.to_date
      tasks = self.all
      
      if from_date.present? and to_date.present?
        tasks = tasks.where('gns_project_tasks.start_date <= ? and gns_project_tasks.end_date >= ?', from_date, from_date)
                .or(tasks.where('gns_project_tasks.end_date >= ? and gns_project_tasks.start_date <= ?', to_date, to_date))
                .or(tasks.where('gns_project_tasks.start_date >= ? and gns_project_tasks.end_date <= ?', from_date, to_date))
      
        total_hours = 0
        number_of_days = 0
        hours_per_day = 0
        num_of_days_by_filter = 0
        
        tasks.each do |t|
          hours_of_task = t.hours.present? ? t.hours : 0
          number_of_days = (t.start_date.to_date..t.end_date.to_date).to_a.size
          
          hours_per_day = (hours_of_task/number_of_days).round(3)
          
          if t.start_date <= from_date
            first_date = from_date
          else
            first_date = t.start_date
          end
          
          if t.end_date >= to_date
            last_date = to_date
          else
            last_date = t.end_date
          end
          
          # Number of task days by filter
          num_of_days_by_filter = (first_date.to_date..last_date.to_date).to_a.size
          
          # Number of task hours by filter
          num_of_hours_by_filter = hours_per_day*num_of_days_by_filter
          
          if num_of_days_by_filter == number_of_days
            num_of_hours_by_filter = hours_of_task
          end
          
          total_hours += num_of_hours_by_filter
        end
        
        return total_hours
      else
        return 0
      end
    end
  end
end
