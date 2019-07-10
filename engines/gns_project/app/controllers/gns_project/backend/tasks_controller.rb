module GnsProject
  module Backend
    class TasksController < GnsCore::Backend::BackendController
      before_action :set_task, only: [:show, :edit, :update, :destroy,
                                      :reopen, :close, :finish, :unfinish, :update_progress,
                                      :attachments, :attachments_list,
                                      :attachment_actions, :download_attachments]
  
      # GET /tasks
      def index
      end
  
      # GET /tasks/1
      def show
        authorize! :read, @task
      end
  
      # GET /tasks/new
      def new        
        @task = Task.new
        @task.project = Project.find(params[:project_id])
        authorize! :create_task, @task.project
        
        working_date = []
        working_date << Time.now.beginning_of_day.strftime('%d/%m/%Y')
        working_date << Time.now.end_of_day.strftime('%d/%m/%Y')
        @workday = working_date.join(" - ")
      end
  
      # POST /tasks
      def create
        @task = Task.new(task_params)
        
        authorize! :create_task, @task.project
        
        @task.creator = current_user
        @task.status = Task::STATUS_OPEN
        
        if params[:task][:workday].present?
          @task.start_date = params[:task][:workday].to_s.split('-')[0].to_date
          @task.end_date = params[:task][:workday].to_s.split('-')[1].to_date
        else
          @task.errors.add('workday', "not be blank")
        end
        
        current_task_id = params.to_unsafe_hash[:task][:current_task_id]
        if current_task_id.present?
          current_task = Task.find(current_task_id)
        end
        
        if @task.save
          # add below stage
          @task.update_custom_order(current_task)
          
          @task.log("gns_project.log.task.created", current_user)
          render json: {
            status: 'success',
            message: 'Task was successfully created.',
          }
        else
          render :new
        end
      end
  
      # GET /tasks/1/edit
      def edit
        authorize! :update, @task
        
        working_date = []
        working_date << @task.start_date.strftime('%d/%m/%Y')
        working_date << @task.end_date.strftime('%d/%m/%Y')
        @workday = working_date.join(" - ")
      end
  
      # PATCH/PUT /tasks/1
      def update
        authorize! :update, @task
        
        # check other model errors
        @task.assign_attributes(task_params)
        @task.valid?
        
        # check if remark empty errors
        #if !params[:remark].present?
        #  @task.errors.add('remark', "not be blank")
        #end
        
        if params[:task][:workday].present?
          @task.start_date = params[:task][:workday].to_s.split('-')[0].to_date
          @task.end_date = params[:task][:workday].to_s.split('-')[1].to_date
        else
          @task.errors.add('workday', "not be blank")
        end
        
        # check error empty?
        if @task.errors.empty?
          @task.save
          
          # project log
          @task.log("gns_project.log.task.updated", current_user, params[:remark])
          
          render json: {
            status: 'success',
            message: 'Task was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /tasks/1
      def destroy
        authorize! :delete, @task
        
        if @task.destroy
          render json: {
            status: 'success',
            message: 'Task was successfully destroyed.',
          }
        else
          render json: {
            status: 'warning',
            message: @task.errors.full_messages.to_sentence
          }
        end
      end
      
      # SELECT2 /tasks
      def select2
        render json: GnsProject::Task.select2(params)
      end
      
      # danh sach attachment cua task
      def attachments
        authorize! :attachments, @task
      end
      
      def attachment_actions
        render layout: nil
      end
      
      def attachments_list
        @attachments = @task.attachments
        
        render layout: nil
      end
      
      # Re-open action
      def reopen
        authorize! :reopen, @task
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.set_open
            
            # log
            @task.log("gns_project.log.task.reopen", current_user, remark)
            
            # send email
            GnsProject::ProjectEmailJob.perform_later(
              GnsProject::ProjectMailer::TYPE_TASK_REOPENED,
              {
                task: @task,
                remark: remark,
                task_link: ENV['web_root'] + gns_project.backend_task_path(@task)
              }
            )
            
            render json: {
              status: 'success',
              message: 'The task was successfully reopened.',
            }
          end
        end
      end
      
      # Close action
      def close
        authorize! :close, @task
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.set_closed
            
            # log
            @task.log("gns_project.log.task.close", current_user, remark)
            
            # send email
            GnsProject::ProjectEmailJob.perform_later(
              GnsProject::ProjectMailer::TYPE_TASK_CLOSED,
              {
                task: @task,
                remark: remark,
                task_link: ENV['web_root'] + gns_project.backend_task_path(@task)
              }
            )
            
            render json: {
              status: 'success',
              message: 'The task has been successfully closed.',
            }
          end
        end
      end
      
      # Finish action
      def finish
        authorize! :finish, @task
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.finish
            
            # log
            @task.log("gns_project.log.task.finish", current_user, remark)
            
            # send email
            GnsProject::ProjectEmailJob.perform_later(
              GnsProject::ProjectMailer::TYPE_TASK_FINISHED,
              {
                task: @task,
                remark: remark,
                task_link: ENV['web_root'] + gns_project.backend_task_path(@task)
              }
            )
            
            render json: {
              status: 'success',
              message: 'The task has been finished.',
            }
          end
        end
      end
      
      # Close action
      def unfinish
        authorize! :unfinish, @task
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.unfinish
            
            # log
            @task.log("gns_project.log.task.unfinish", current_user, remark)
            
            # send email
            GnsProject::ProjectEmailJob.perform_later(
              GnsProject::ProjectMailer::TYPE_TASK_UNFINISHED,
              {
                task: @task,
                remark: remark,
                task_link: ENV['web_root'] + gns_project.backend_task_path(@task)
              }
            )
            
            render json: {
              status: 'success',
              message: 'The task has been unfinished.',
            }
          end
        end
      end
      
      # update progress for task action
      def update_progress
        if request.post?
          @task.progress = params[:progress]
          remark = params[:remark]
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.save
            @task.log("gns_project.log.task.update_progress", current_user, remark)
            
            render json: {
              status: 'success',
              message: 'Task progress has been updated.',
            }
          end
        end
      end
      
      def download_attachments
        authorize! :download_attachments, @task
        
        filename = "#{@task.name}.zip"
        t = Tempfile.new(filename)
        # Give the path of the temp file to the zip outputstream, it won't try to open it as an archive.
        Zip::OutputStream.open(t.path) do |zos|
          @task.attachments.each do |att|
            file = File.read(att.file_path)
            # Create a new entry with some arbitrary name
            zos.put_next_entry(@task.stage.name + '/' + @task.name + '/' + att.original_name)
            # Add the contents of the file, don't read the stuff linewise if its binary, instead use direct IO
            zos.puts file
          end
        end
        
        # End of the block  automatically closes the file.
        # Send it using the right mime type, with a download window and some nice file name.
        send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => filename
        # The temp file will be deleted some time...
        t.close
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_task
          @task = Task.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def task_params
          params.fetch(:task, {}).permit(:name, :project_id, :stage_id, :start_date, :end_date, :employee_id, :hours)
        end
    end
  end
end
