class AddParentToGnsContactCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_contact_categories, :parent, index: true, references: :gns_contact_categories
  end
end
