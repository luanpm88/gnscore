class AddForeignNameToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :foreign_name, :string
  end
end
