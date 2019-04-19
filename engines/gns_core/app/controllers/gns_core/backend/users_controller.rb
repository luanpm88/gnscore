module GnsCore
  module Backend
    class UsersController < GnsCore::Backend::BackendController
      before_action :set_user, only: [:show, :edit, :update]
  
      # GET /users
      def index
      end
      
      # POST /users/list
      def list
        @users = User.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /users/1
      def show
      end
  
      # GET /users/new
      def new
        @user = User.new
      end
  
      # GET /users/1/edit
      def edit
      end
  
      # POST /users
      def create
        @user = User.new(user_params)
  
        if @user.save
          # Add notification
          current_user.add_notification("gns_core.notification.user.created", {
            name: @user.full_name
          })
          
          flash[:success] = 'User was successfully created.'
          render json: {
            redirect: gns_core.backend_user_path(@user)
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /users/1
      def update
        if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end
        
        if @user.update(user_params)
          # Add notification
          current_user.add_notification("gns_core.notification.user.updated", {
            name: @user.full_name
          })
          
          render json: {
            status: 'success',
            message: 'User was successfully updated.',
          }
        else
          render :edit
        end
      end
      
      def select2
        render json: User.select2(params)
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def user_params
          params.fetch(:user, {}).permit(:avatar, :first_name, :last_name, :email, :password,
                                         role_ids: [])
        end
    end
  end
end
