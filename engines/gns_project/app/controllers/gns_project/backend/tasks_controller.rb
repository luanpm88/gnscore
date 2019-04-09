module GnsProject
  module Backend
    class TasksController < GnsCore::Backend::BackendController
      before_action :set_task, only: [:show, :edit, :update, :destroy,
                                      :reopen, :close, :finish, :unfinish, :update_progress,
                                      :attachments, :attachments_list, :download_attachments]
  
      # GET /tasks
      def index
      end
  
      # GET /tasks/1
      def show
      end
  
      # GET /tasks/new
      def new
        @task = Task.new
        @task.project = Project.find(params[:project_id])
      end
  
      # GET /tasks/1/edit
      def edit
      end
  
      # POST /tasks
      def create
        @task = Task.new(task_params)
        
        @task.status = Task::STATUS_OPEN
        
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
  
      # PATCH/PUT /tasks/1
      def update
        remark = params[:remark]
        
        if !remark.present?
          @task.errors.add('remark', "not be blank")
        end
        
        if @task.errors.empty?
          if @task.update(task_params)
            @task.log("gns_project.log.task.updated", current_user, remark)
            
            render json: {
              status: 'success',
              message: 'Task was successfully updated.',
            }
          else
            render :edit
          end
        else
          render :edit
        end
      end
  
      # DELETE /tasks/1
      def destroy
        @task.destroy
        
        render json: {
          status: 'success',
          message: 'Task was successfully destroyed.',
        }
      end
      
      # SELECT2 /tasks
      def select2
        render json: GnsProject::Task.select2(params)
      end
      
      # danh sach attachment cua task
      def attachments
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
            @task.log("gns_project.log.task.reopen", current_user, remark)
            
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
            @task.log("gns_project.log.task.close", current_user, remark)
            
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
            @task.log("gns_project.log.task.finish", current_user, remark)
            
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
            @task.log("gns_project.log.task.unfinish", current_user, remark)
            
            render json: {
              status: 'success',
              message: 'The task has been unfinished.',
            }
          end
        end
      end
      
      # update progress for task action
      def update_progress
        progress = params[:progress]
        remark = params[:remark]
        
        if request.post?
          if !progress.present?
            @task.errors.add('progress', "not be blank")
          end
          
          if !remark.present?
            @task.errors.add('remark', "not be blank")
          end
          
          if @task.errors.empty?
            @task.update_columns(progress: progress)
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
