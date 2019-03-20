class AddDescriptionToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :description, :text
  end
end
