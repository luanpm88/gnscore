class CreateGnsAreaStates < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_area_states do |t|
      t.string :name
      t.references :country, index: true, references: :gns_area_countries

      t.timestamps
    end
  end
end
