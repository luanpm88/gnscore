class AddCacheSearchToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :cache_search, :text
  end
end
