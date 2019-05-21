class AddActiveToGnsContactCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_contact_categories, :active, :boolean, default: true
  end
end
