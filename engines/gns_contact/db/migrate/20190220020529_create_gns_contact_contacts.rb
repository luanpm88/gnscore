class CreateGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_contact_contacts do |t|
      t.string :full_name
      t.string :email
      t.string :phone
      t.string :address
      
      t.timestamps
    end
  end
end
