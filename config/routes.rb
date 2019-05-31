Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount GnsCore::Engine => "/", as: 'gns_core'
  mount GnsArea::Engine => "/", as: 'gns_area'
  mount GnsContact::Engine => "/", as: 'gns_contact'
  mount GnsProject::Engine => "/", as: 'gns_project'
  mount GnsNotification::Engine => "/", as: 'gns_notification'
  mount GnsEmployee::Engine => "/", as: 'gns_employee'
  mount GnsReport::Engine => "/", as: 'gns_report'
end
