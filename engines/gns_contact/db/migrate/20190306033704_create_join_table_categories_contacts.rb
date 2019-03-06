class CreateJoinTableCategoriesContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_contact_categories_contacts do |t|
      t.references :category, index: true, references: :gns_contact_categories
      t.references :contact, index: true, references: :gns_contact_contacts
    end
  end
end
