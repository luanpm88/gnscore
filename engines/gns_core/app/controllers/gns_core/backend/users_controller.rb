module GnsCore
  module Backend
    class UsersController < GnsCore::Backend::BackendController
      before_action :set_user, only: [:edit, :update]

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
          params.fetch(:user, {}).permit(:name, :email, :password)
        end
    end
  end
end
