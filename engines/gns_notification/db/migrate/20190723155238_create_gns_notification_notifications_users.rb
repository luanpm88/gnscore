class CreateGnsNotificationNotificationsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_notification_notifications_users do |t|
      t.references :notification, index: true, references: :gns_notification_notifications
      t.references :user, index: true, references: :gns_core_users
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
