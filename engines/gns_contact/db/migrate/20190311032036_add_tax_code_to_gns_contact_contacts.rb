class AddTaxCodeToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :tax_code, :string
  end
end
