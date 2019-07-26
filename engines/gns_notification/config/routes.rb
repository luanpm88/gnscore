GnsNotification::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
        namespace :backend, module: "backend", path: "backend/notification" do
            resources :notifications_users do
                collection do
                    get 'notifications_box'
                    get 'notification_unread_count'
                    get 'your_notifications'
                end
            end
        end
    end
end
