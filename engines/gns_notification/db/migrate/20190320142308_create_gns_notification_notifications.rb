class CreateGnsNotificationNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_notification_notifications do |t|
      t.string :phrase
      t.text :data
      t.references :user, index: true, references: :gns_core_users

      t.timestamps
    end
  end
end
