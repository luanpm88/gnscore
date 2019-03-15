module GnsProject
  module Backend
    class TasksController < GnsCore::Backend::BackendController
      before_action :set_task, only: [:attachments, :show, :edit, :update, :destroy]
  
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
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_task
          @task = Task.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def task_params
          params.fetch(:task, {}).permit(:name, :project_id, :stage_id)
        end
    end
  end
end
