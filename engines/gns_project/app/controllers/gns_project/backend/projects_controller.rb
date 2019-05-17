module GnsProject
  module Backend
    class ProjectsController < GnsCore::Backend::BackendController
      before_action :set_project, only: [:download_attachments, :show, :edit, :update, :destroy,
                                         :tasks, :tasks_list, :attachments, :attachments_list,
                                         :logs, :logs_list, :authorization, :authorization_list,
                                         :comments, :send_request, :start_progress, :finish]
  
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
        authorize! :create, GnsProject::Project
        
        @project = Project.new
        
        date = []
        date << Time.now.beginning_of_day.strftime('%d/%m/%Y')
        date << Time.now.end_of_day.strftime('%d/%m/%Y')
        @date_of_implementation = date.join(" - ")
      end
  
      # POST /projects
      def create
        authorize! :create, GnsProject::Project
        
        @project = Project.new(project_params)
        
        @project.creator = current_user
        @project.status = Project::STATUS_NEW
        
        if params[:project][:date_of_implementation].present?
          @project.start_date = params[:project][:date_of_implementation].to_s.split('-')[0].to_date
          @project.end_date = params[:project][:date_of_implementation].to_s.split('-')[1].to_date
        else
          @project.errors.add('date', "not be blank")
        end
  
        if @project.save
          # add log
          @project.log("gns_project.log.project.created", current_user)
          
          # add notification
          current_user.add_notification("gns_project.notification.project.created", {
            name: @project.name
          })
          
          flash[:success] = 'Project was successfully created.'
          render json: {
            redirect: gns_project.tasks_backend_projects_path(@project)
          }
        else
          render :new
        end
      end
  
      # GET /projects/1/edit
      def edit
        authorize! :update, @project
        
        date = []
        date << @project.start_date.strftime('%d/%m/%Y')
        date << @project.end_date.strftime('%d/%m/%Y')
        @date_of_implementation = date.join(" - ")
      end
  
      # PATCH/PUT /projects/1
      def update
        authorize! :update, @project
        
        if params[:project][:date_of_implementation].present?
          @project.start_date = params[:project][:date_of_implementation].to_s.split('-')[0].to_date
          @project.end_date = params[:project][:date_of_implementation].to_s.split('-')[1].to_date
        else
          @project.errors.add('date', "not be blank")
        end
        
        if @project.update(project_params)          
          # add log
          @project.log("gns_project.log.project.updated", current_user)
          
          # add notification
          current_user.add_notification("gns_project.notification.project.updated", {
            name: @project.name
          })
          
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
        authorize! :delete, @project
        
        # add log
        @project.log("gns_project.log.project.deleted", current_user)
        
        # add notification
        current_user.add_notification("gns_project.notification.project.deleted", @project.to_json)
        
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
        @project_employees = GnsProject::ProjectEmployee.where(project_id: @project.id)
        render layout: nil
      end
      
      def authorization_permissions
        @project_employee = GnsProject::ProjectEmployee.find(params[:project_employee_id])
      end
      
      # add authorization
      def add_authorization
        @project_employee = GnsProject::ProjectEmployee.new
        @project = Project.find(params[:project_id])
        
        if request.post?
          eid = params[:authorization][:employee_id]
          role_ids = params[:authorization][:role_ids]
          #@employee = GnsEmployee::Employee.find(eid)
          
          if !eid.present?
            @project_employee.errors.add('employee', "not be blank")
          end
          
          if !role_ids.present?
            @project_employee.errors.add('role_ids', "not be blank")
          end
          
          if @project_employee.errors.empty?
            role_ids.each do |rid|
              @project.add_employee_role(eid, rid)
            end
            
            @project_employee = GnsProject::ProjectEmployee.where(project_id: @project.id, employee_id: eid).first
            
            # add log
            @project_employee.log("gns_project.log.project_employee.added", current_user)
            
            # add notification
            current_user.add_notification("gns_project.notification.project_employee.added", {
              project_name: @project.name,
              user_name: @project_employee.employee_name
            })
            
            render json: {
              status: 'success',
              message: 'Authorization was successfully added.',
            }
          end
        end
      end
      
      # edit authorization
      def update_authorization
        @project_employee = GnsProject::ProjectEmployee.find(params[:project_employee_id])
        @project = @project_employee.project
        
        if request.post?
          eid = params[:authorization][:employee_id]
          role_ids = params[:authorization][:role_ids]
          @employee = GnsEmployee::Employee.find(eid)
          
          if !eid.present?
            @project_employee.errors.add('employee_id', "not be blank")
          end
          
          if !role_ids.present?
            @project_employee.errors.add('role_ids', "not be blank")
          end
          
          if @project_employee.errors.empty?
            @project.update_employee_roles(@employee, role_ids)
            
            # add log
            @project_employee.log("gns_project.log.project_employee.updated", current_user)
            
            # add notification
            current_user.add_notification("gns_project.notification.project_employee.updated", {
              project_name: @project.name,
              user_name: @project_employee.employee_name
            })
            
            render json: {
              status: 'success',
              message: 'Authorization was successfully updated.',
            }
          end
        end
      end
      
      # edit authorization
      def remove_authorization
        @project_employee = GnsProject::ProjectEmployee.find(params[:project_employee_id])
        @project = @project_employee.project
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @project_employee.errors.add('remark', "not be blank")
          end
          
          if @project_employee.errors.empty?
            # add log
            @project_employee.log("gns_project.log.project_employee.removed", current_user, remark)
            
            # add notification
            current_user.add_notification("gns_project.notification.project_employee.removed", {
              project_name: @project.name,
              user_name: @project_employee.employee_name
            })
            
            @project.remove_project_employee(@project_employee)
            
            render json: {
              status: 'success',
              message: 'Authorization was successfully removed.',
            }
          end
        end
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
      
        render layout: nil
      end
      
      # Set Pending action
      def send_request
        authorize! :send_request, @project
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @project.errors.add('remark', "not be blank")
          end
          
          if @project.errors.empty?
            @project.set_pending_for_status
            
            # add log
            @project.log("gns_project.log.project.request", current_user, remark)
            
            # add notification
            current_user.add_notification("gns_project.notification.project.request", {
              name: @project.name
            })
            
            render json: {
              status: 'success',
              message: 'Request for approval for the project has been successfully submitted.',
            }
          end
        end
      end
      
      # Set InProgress action
      def start_progress
        #authorize! :set_in_progress, @project
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @project.errors.add('remark', "not be blank")
          end
          
          if @project.errors.empty?
            @project.set_in_progress_for_status
            
            # add log
            @project.log("gns_project.log.project.start_progress", current_user, remark)
            
            # add notification
            current_user.add_notification("gns_project.notification.project.start_progress", {
              name: @project.name
            })
            
            render json: {
              status: 'success',
              message: 'The project has successfully updated the status is "in progress".',
            }
          end
        end
      end
      
      # Set Finished action
      def finish
        #authorize! :set_finished, @project
        
        remark = params[:remark]
        
        if request.post?
          if !remark.present?
            @project.errors.add('remark', "not be blank")
          end
          
          if @project.errors.empty?
            @project.set_finished_for_status
            
            # add log
            @project.log("gns_project.log.project.finish", current_user, remark)
            
            # add notification
            current_user.add_notification("gns_project.notification.project.finish", {
              name: @project.name
            })
            
            render json: {
              status: 'success',
              message: 'The project has successfully updated the status is "finished".',
            }
          end
        end
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
        end
        def comment_params
          params.fetch(:comment, {}).permit(:message, :file, :project_id, :parent_id)
        end
    end
  end
end
