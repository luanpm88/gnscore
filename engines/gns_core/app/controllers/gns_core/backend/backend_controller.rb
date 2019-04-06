module GnsCore::Backend
	class BackendController < GnsCore::ApplicationController
    layout :set_layout
    before_action :authenticate_user!
    
    rescue_from CanCan::AccessDenied do |exception|
			render :file => "gns_core/static/403.html", :status => 403, :layout => false
		end
    
    private
			def set_layout
				"gns_ux/backend/index"
			end
  end
end