class AddClassNameToGnsNotificationNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_notification_notifications, :class_name, :string
  end
end
