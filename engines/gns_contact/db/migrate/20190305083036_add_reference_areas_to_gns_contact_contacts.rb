class AddReferenceAreasToGnsContactContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_contact_contacts, :country, index: true, references: :gns_area_countries
    add_reference :gns_contact_contacts, :state, index: true, references: :gns_area_states
    add_reference :gns_contact_contacts, :district, index: true, references: :gns_area_districts
  end
end
