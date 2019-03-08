class CreateGnsContactParentContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_contact_parent_contacts do |t|
      t.references :parent, index: true, references: :gns_contact_contacts
      t.references :contact, index: true, references: :gns_contact_contacts
      
      t.timestamps
    end
  end
end
