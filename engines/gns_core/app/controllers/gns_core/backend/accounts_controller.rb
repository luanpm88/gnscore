module GnsCore
  module Backend
    class AccountsController < GnsCore::Backend::BackendController
      before_action :set_account, only: [:my_profile, :my_account,
                                         :update_account, :update_password]
  
      # GET /accounts
      def my_profile
      end
      
      def my_account
      end
  
      def update_account
        if params.present?
          if !params[:username].present?
            @account.errors.add('username', "not be blank")
          end
          
          if @account.errors.empty?
            @account.avatar = params[:avatar]
            @account.first_name = params[:username]
            
            if @account.save
              redirect_to gns_core.my_account_backend_accounts_path, notice: 'Account was successfully created.'
            end
          end
        end
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_account
          @account = current_user
        end
  
        # Only allow a trusted parameter "white list" through.
        def account_params
          params.fetch(:account, {})
        end
    end
  end
end
