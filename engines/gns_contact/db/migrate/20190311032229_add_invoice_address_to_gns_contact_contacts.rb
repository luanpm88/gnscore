class AddInvoiceAddressToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_contacts, :invoice_address, :string
  end
end
