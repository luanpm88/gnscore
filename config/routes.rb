Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount GnsCore::Engine => "/", as: 'gns_core'
  mount GnsArea::Engine => "/", as: 'gns_area'
  mount GnsContact::Engine => "/", as: 'gns_contact'
  mount GnsProject::Engine => "/", as: 'gns_project'
  mount GnsNotification::Engine => "/", as: 'gns_notification'
end
