class AddDescriptionToGnsProjectCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_categories, :description, :text
  end
end
