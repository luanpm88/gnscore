class AddCustomerIdToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_project_projects, :customer, index: true, references: :gns_contact_contacts
  end
end
