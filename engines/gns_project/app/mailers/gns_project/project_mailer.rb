module GnsProject
  class ProjectMailer < GnsCore::ApplicationMailer
    TYPE_PROJECT_STARTED = 'project_started'
    TYPE_TASK_CLOSED = 'task_closed'
    TYPE_TASK_REOPENED = 'task_reopened'
    TYPE_TASK_UNFINISHED = 'task_unfinished'
    TYPE_TASK_FINISHED = 'task_finished'
    
    def self.run(type, options)
      if type == self::TYPE_PROJECT_STARTED
        eval("self.send_#{type}_emails(options)")
      else
        eval("send_#{type}_email(options)").deliver_now
      end
    end
    
    # send project started emails
    def self.send_project_started_emails(options)
      @project = options[:project]
      @tasks = @project.tasks
      
      #@todo static emails
      employee_ids = @tasks.map(&:employee_id).uniq
      
      @recipients = GnsEmployee::Employee.where(id: employee_ids)
      
      @recipients.each do |recipient|
        send_project_started_email(recipient, @project).deliver_now
      end
    end
    
    def send_project_started_email(recipient, project)
      @project = project
      @tasks = @project.tasks
      @name = recipient.name
      send_email("#{recipient.user.email}", "#{project.code}: You have been assigned to the project")
    end
    
    # task finished email notification
    def send_task_finished_email(options)
      @task = options[:task]
      @remark = options[:remark]
      @task_link = options[:task_link]
      send_email(@task.employee_email, "Task Finished - #{@task.name} (Project code: #{@task.project_code})") if @task.employee_email.present?
    end
    
    # task un-finished email notification
    def send_task_unfinished_email(options)
      @task = options[:task]
      @remark = options[:remark]
      @task_link = options[:task_link]
      send_email(@task.employee_email, "Task Un-finished - #{@task.name} (Project code: #{@task.project_code})") if @task.employee_email.present?
    end
    
    # task closed email notification
    def send_task_closed_email(options)
      @task = options[:task]
      @remark = options[:remark]
      @task_link = options[:task_link]
      send_email(@task.employee_email, "Task Closed - #{@task.name} (Project code: #{@task.project_code})") if @task.employee_email.present?
    end
    
    # task reopen email notification
    def send_task_reopened_email(options)
      @task = options[:task]
      @remark = options[:remark]
      @task_link = options[:task_link]
      send_email(@task.employee_email, "Task Re-opened - #{@task.name} (Project code: #{@task.project_code})") if @task.employee_email.present?
    end
    
  end
end