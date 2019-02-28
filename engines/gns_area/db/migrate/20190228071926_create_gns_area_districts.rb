class CreateGnsAreaDistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_area_districts do |t|
      t.string :name
      t.references :state, index: true, references: :gns_area_states

      t.timestamps
    end
  end
end
