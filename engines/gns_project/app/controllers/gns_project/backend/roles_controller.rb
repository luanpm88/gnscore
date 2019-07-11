module GnsProject
  module Backend
    class RolesController < GnsCore::Backend::BackendController
      before_action :set_role, only: [:permissions, :update_permissions,
                                      :edit, :update, :destroy,
                                      :activate, :deactivate]
  
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
        authorize! :set_permissions, @role
      end
      
      def update_permissions
        authorize! :set_permissions, @role
        
        if params[:permissions].present?
          params[:permissions].each do |p|
            if p[1] == 'true'
              @role.add_permission(p[0])
            else
              @role.remove_permission(p[0])
            end
          end
          
          # Add notification
          current_user.add_notification("gns_project.notification.role.update_permissions", @role)
          
          flash[:success] = 'Project role has been updated policies successfully.'
          redirect_to gns_project.backend_roles_path
        end
      end
  
      # GET /roles/new
      def new
        authorize! :create, GnsProject::Role
        
        @role = Role.new
      end
  
      # POST /roles
      def create
        authorize! :create, GnsProject::Role
        
        @role = Role.new(role_params)
        
        @role.creator = current_user
  
        if @role.save
          # Add notification
          current_user.add_notification("gns_project.notification.role.created", @role)
          
          flash[:success] = 'Project role was successfully created.'
          render json: {
            redirect: gns_project.permissions_backend_roles_path(@role)
          }
        else
          render :new
        end
      end
  
      # GET /roles/1/edit
      def edit
        authorize! :update, @role
      end
  
      # PATCH/PUT /roles/1
      def update
        authorize! :update, @role
        
        if @role.update(role_params)
          # Add notification
          current_user.add_notification("gns_project.notification.role.updated", @role)
          
          render json: {
            status: 'success',
            message: 'Project role was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /roles/1
      def destroy
        authorize! :delete, @role
        
        # Add notification
        current_user.add_notification("gns_project.notification.role.deleted", @role)
        
        if @role.destroy
          render json: {
            status: 'success',
            message: 'The role was successfully destroyed.',
          }
        else
          render json: {
            status: 'warning',
            message: @role.errors.full_messages.to_sentence
          }
        end
      end
      
      # SELECT2 /roles
      def select2
        render json: GnsProject::Role.select2(params)
      end
      
      # ACTIVATE /roles/1
      def activate
        authorize! :activate, @role
        
        @role.activate
        
        # Add notification
        current_user.add_notification("gns_project.notification.role.activate", @role)
        
        render json: {
          status: 'success',
          message: 'Project role was successfully activated.',
        }
      end
      
      # DEACTIVATE /roles/1
      def deactivate
        authorize! :deactivate, @role
        
        @role.deactivate
        
        # Add notification
        current_user.add_notification("gns_project.notification.role.deactivate", @role)
        
        render json: {
          status: 'success',
          message: 'Project role was successfully deactivated.',
        }
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
