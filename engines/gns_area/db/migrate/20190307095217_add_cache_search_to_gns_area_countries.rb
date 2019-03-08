class AddCacheSearchToGnsAreaCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_area_countries, :cache_search, :text
  end
end
