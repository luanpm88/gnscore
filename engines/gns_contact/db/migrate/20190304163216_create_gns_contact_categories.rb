class CreateGnsContactCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_contact_categories do |t|
      t.string :name
      t.text :cache_search

      t.timestamps
    end
  end
end
