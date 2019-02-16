class CreateGnsCoreContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_core_contacts do |t|

      t.timestamps
    end
  end
end
