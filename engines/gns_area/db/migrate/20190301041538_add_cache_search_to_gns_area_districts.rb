class AddCacheSearchToGnsAreaDistricts < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_area_districts, :cache_search, :text
  end
end
