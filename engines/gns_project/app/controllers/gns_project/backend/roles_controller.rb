module GnsProject
  module Backend
    class RolesController < GnsCore::Backend::BackendController
      before_action :set_role, only: [:permissions, :edit, :update, :destroy]
  
      # GET /roles
      def index
      end
  
      # GET /roles/list
      def list
        @roles = Role.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
      
      # GET /roles/1
      def permissions
      end
      
      def update_permissions
        @role = Role.find(params[:id])
        
        if params[:permissions].present?
          params[:permissions].each do |p|
            if p[1] == 'true'
              @role.add_permission(p[0])
            else
              @role.remove_permission(p[0])
            end
          end
          
          # Add notification
          current_user.add_notification("gns_project.notification.role.update_permissions", {
            name: @role.name
          })
          
          flash[:success] = 'Project role has been updated policies successfully.'
          redirect_to gns_project.backend_roles_path
        end
      end
  
      # GET /roles/new
      def new
        @role = Role.new
      end
  
      # GET /roles/1/edit
      def edit
      end
  
      # POST /roles
      def create
        @role = Role.new(role_params)
  
        if @role.save
          # Add notification
          current_user.add_notification("gns_project.notification.role.created", {
            name: @role.name
          })
          
          flash[:success] = 'Project role was successfully created.'
          render json: {
            redirect: gns_project.permissions_backend_roles_path(@role)
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /roles/1
      def update
        if @role.update(role_params)
          # Add notification
          current_user.add_notification("gns_project.notification.role.updated", {
            name: @role.name
          })
          
          render json: {
            status: 'success',
            message: 'Project role was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /roles/1
      #def destroy
      #  @role.destroy
      #  redirect_to roles_url, notice: 'Role was successfully destroyed.'
      #end
      
      # SELECT2 /stages
      def select2
        render json: GnsProject::Role.select2(params)
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_role
          @role = Role.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def role_params
          params.fetch(:role, {}).permit(:name, :active)
        end
    end
  end
end
