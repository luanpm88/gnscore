class CreateGnsAreaCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_area_countries do |t|
      t.string :name

      t.timestamps
    end
  end
end
