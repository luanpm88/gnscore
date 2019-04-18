module GnsProject
  module Backend
    class ProjectsController < GnsCore::Backend::BackendController
      before_action :set_project, only: [:download_attachments, :show, :edit, :update, :destroy,
                                         :tasks, :tasks_list, :attachments, :attachments_list,
                                         :logs, :logs_list, :authorization, :authorization_list,
                                         :add_authorization, :comments]
  
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
        
        @project.creator = current_user
        @project.status = Project::STATUS_NEW
  
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
      end
      
      def tasks_list
        @tasks = @project.tasks.order(:custom_order)
        
        render layout: nil
      end
      
      # task list ajax table / project planning
      def attachments
      end
      
      def attachments_list
        @tasks = @project.tasks.order(:custom_order)
        
        render layout: nil
      end
      
      def logs_list
        @logs = @project.logs.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
      
      # Authorization
      def authorization
      end
      
      def authorization_list
        @project_user_roles = GnsProject::ProjectUserRole.all
        render layout: nil
      end
      
      # add authorization
      def add_authorization
        #authorization[project_id]
        #authorization[user_id]
        #authorization[role_ids][]
        #
        #add project_id ==> ProjectUser
        #add user_id ==> ProjectUser
        #add role_ids ==> ProjectUserRole
      end
      
      def download_attachments
        authorize! :download_attachments, @project
        
        filename = "#{@project.code}.zip"
        t = Tempfile.new(filename)
        # Give the path of the temp file to the zip outputstream, it won't try to open it as an archive.
        Zip::OutputStream.open(t.path) do |zos|
          @project.tasks.each do |task|
            task.attachments.each do |att|
              file = File.read(att.file_path)
              # Create a new entry with some arbitrary name
              zos.put_next_entry(task.stage.name + '/' + task.name + '/' + att.original_name)
              # Add the contents of the file, don't read the stuff linewise if its binary, instead use direct IO
              zos.puts file
            end
          end
        end
        
        # End of the block  automatically closes the file.
        # Send it using the right mime type, with a download window and some nice file name.
        send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@project.code}.zip"
        # The temp file will be deleted some time...
        t.close
      end
      
      # note/comment      
      def comments      
        @comments = @project.comments.order('created_at DESC')
          .where(parent_id: nil)
          .paginate(:page => params[:page], :per_page => 5)
      
        render layout: nil
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_project
          @project = Project.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def project_params
          params.fetch(:project, {}).permit(:code, :name, :category_id, :customer_id,
                                            :start_date, :end_date, :priority, :manager_id)
          
          def comment_params
            params.fetch(:comment, {}).permit(:message, :file, :project_id, :parent_id)
          end
        end
    end
  end
end
