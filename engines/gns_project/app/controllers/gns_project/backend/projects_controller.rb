module GnsProject::Backend
  class ProjectsController < GnsCore::Backend::BackendController
    before_action :set_project, only: [:show, :edit, :update, :destroy]

    # GET /projects
    def index
    end
    
    # POST /projects/list
    def list
      @projects = GnsProject::Project.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
      
      render layout: nil
    end

    # GET /projects/1
    def show
    end

    # GET /projects/new
    def new
      @project = GnsProject::Project.new
    end

    # GET /projects/1/edit
    def edit
    end

    # POST /projects
    def create
      @project = GnsProject::Project.new(project_params)

      if @project.save
        respond_to do |format|
          format.html {
            flash[:success] = 'Project was successfully created.'
            redirect_to gns_project.backend_projects_path
          }
          format.json {
            render json: {
              status: 'success',
              message: 'The project was successfully created.',
            }
          }
        end
      else
        render :new
      end
    end

    # PATCH/PUT /projects/1
    def update
      if @project.update(project_params)
        respond_to do |format|
          format.html {
            flash[:success] = 'Project was successfully updated.'
            redirect_to gns_project.backend_projects_path
          }
          format.json {
            render json: {
              status: 'success',
              message: 'The project was successfully updated.',
            }
          }
        end
      else
        render :edit
      end
    end

    # DELETE /projects/1
    def destroy
      @project.destroy
      
      respond_to do |format|
        format.html {
          flash[:success] = 'Project was successfully destroyed.'
          redirect_to gns_project.backend_categories_path
        }
        format.json {
          render json: {
            status: 'success',
            message: 'The project was successfully deleted.',
          }
        }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_project
        @project = GnsProject::Project.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def project_params
        params.fetch(:project, {}).permit(:code, :name, :category_id, :customer_id)
      end
  end
end
