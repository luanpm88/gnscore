class AddCreatorToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_contact_contacts, :creator, index: true, references: :gns_core_users
  end
end
