class AddContactTypeToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :contact_type, :string
  end
end
