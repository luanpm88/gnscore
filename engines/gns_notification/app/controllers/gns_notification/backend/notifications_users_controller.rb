module GnsNotification
  module Backend
    class NotificationsUsersController < GnsCore::Backend::BackendController
      def notifications_box
        @notifications_users = current_user.notifications_users.order('created_at desc').limit(20)
        @notifications_users.read
        
        render layout: nil
      end
      
      def notification_unread_count
        
        render layout: nil
      end
      
      def your_notifications
        @notifications_users = current_user.notifications_users.order('created_at desc')
        @notifications_users.read
      end
    end
  end
end
