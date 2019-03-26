class AddActiveToGnsProjectCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_categories, :active, :boolean, default: true
  end
end
