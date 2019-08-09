class CreateGnsNotePersonalNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_note_personal_notes do |t|
      t.string :description
      t.datetime :due_date
      t.boolean :is_done, default: false
      t.references :user, index: true, references: :gns_core_users

      t.timestamps
    end
  end
end
