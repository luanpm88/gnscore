class AddCacheSearchToGnsAreaStates < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_area_states, :cache_search, :text
  end
end
