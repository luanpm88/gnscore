module GnsCore::Backend
	class BackendController < GnsCore::ApplicationController
    layout :set_layout
    before_action :authenticate_user!
    
    private
			def set_layout
				"gns_ux/backend/index"
			end
  end
end