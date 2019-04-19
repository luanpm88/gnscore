module GnsCore
  module ApplicationHelper
    # Status /list page
    def status_badge(status)
      status.present? ? "<span class=\'badge badge-#{status}\'>#{t('.' + status)}</span>".html_safe : ''
    end
  end
end
