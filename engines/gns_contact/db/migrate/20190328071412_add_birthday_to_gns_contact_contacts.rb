class AddBirthdayToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :birthday, :datetime
  end
end
