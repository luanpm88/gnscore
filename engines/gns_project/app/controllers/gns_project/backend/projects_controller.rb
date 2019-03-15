module GnsProject
  module Backend
    class ProjectsController < GnsCore::Backend::BackendController
      before_action :set_project, only: [:tasks, :tasks_attachment, :show, :edit, :update, :destroy]
  
      # GET /projects
      def index
      end
      
      # POST /projects/list
      def list
        @projects = Project.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /projects/1
      def show
      end
  
      # GET /projects/new
      def new
        @project = Project.new
      end
  
      # GET /projects/1/edit
      def edit
      end
  
      # POST /projects
      def create
        @project = Project.new(project_params)
  
        if @project.save
          flash[:success] = 'Project was successfully created.'
          render json: {
            redirect: gns_project.backend_project_path(@project)
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /projects/1
      def update
        if @project.update(project_params)
          render json: {
            status: 'success',
            message: 'Project was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /projects/1
      def destroy        
        if @project.destroy
          respond_to do |format|
            format.html {
              flash[:success] = 'Project was successfully destroyed.'
              redirect_to gns_project.backend_projects_path
            }
            format.json {
              render json: {
                status: 'success',
                message: 'Project was successfully deleted.',
              }
            }
          end
        else
          respond_to do |format|
            format.html {
              flash[:warning] = @project.errors.full_messages.to_sentence
              redirect_to gns_project.backend_projects_path
            }
            format.json {
              render json: {
                status: 'warning',
                message: @project.errors.full_messages.to_sentence
              }
            }
          end
        end
        
      end
      
      # task list ajax table / project planning
      def tasks
        render layout: nil
      end
      
      # task list ajax table / project planning
      def tasks_attachment
        render layout: nil
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_project
          @project = Project.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def project_params
          params.fetch(:project, {}).permit(:code, :name, :category_id, :customer_id)
        end
    end
  end
end
