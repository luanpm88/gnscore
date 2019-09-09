class AddReminderToGnsNotePersonalNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_note_personal_notes, :reminder, :string
  end
end
