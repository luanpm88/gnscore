class AddActiveToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :active, :boolean, default: true
  end
end
