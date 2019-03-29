module GnsProject
  module Backend
    class TasksController < GnsCore::Backend::BackendController
      before_action :set_task, only: [:show, :edit, :update, :destroy,
                                      :reopen, :close, :attachments]
  
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
        if @task.save
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
        if @task.update(task_params)
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
        render layout: nil
      end
      
      # Re-open action
      def reopen
        @task.set_open
        
        render json: {
          status: 'success',
          message: 'The task was successfully reopened.',
        }
      end
      
      # Close action
      def close
        @task.set_closed
        
        render json: {
          status: 'success',
          message: 'The task has been successfully closed.',
        }
      end
      
      # Finish action
      def finish
        @task.finish
        
        render json: {
          status: 'success',
          message: 'The task has been finished.',
        }
      end
      
      # Close action
      def unfinish
        @task.unfinish
        
        render json: {
          status: 'success',
          message: 'The task has been unfinished.',
        }
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_task
          @task = Task.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def task_params
          params.fetch(:task, {}).permit(:name, :project_id, :stage_id, :start_date, :end_date, :employee_id)
        end
    end
  end
end
