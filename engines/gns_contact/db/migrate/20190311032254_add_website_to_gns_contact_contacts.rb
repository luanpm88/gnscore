class AddWebsiteToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :website, :string
  end
end
