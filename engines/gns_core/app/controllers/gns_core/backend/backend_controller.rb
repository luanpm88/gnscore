module GnsCore::Backend
	class BackendController < GnsCore::ApplicationController
    layout :set_layout
    
    private
			def set_layout
				if request.xhr?
					nil
				else
					"gns_ux/backend/main"
				end
			end
  end
end