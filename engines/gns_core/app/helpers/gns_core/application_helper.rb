module GnsCore
  module ApplicationHelper
    # Status /list page
    def status_badge(status)
      status.present? ? "<span class=\'badge badge-#{status}\'>#{t('.' + status)}</span>".html_safe : ''
    end
    
    def display_address(object)
      str = []
      str << object.address if object.address.present?
      str << object.district_name if object.district_name.present?
      str << object.state_name if object.state_name.present?
      str << object.country_name if object.country_name.present?
      return str.join(", ")
    end
  end
end
