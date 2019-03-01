class AddCacheSearchToGnsProjectCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_categories, :cache_search, :text
  end
end
