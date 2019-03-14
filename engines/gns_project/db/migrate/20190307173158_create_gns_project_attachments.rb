class CreateGnsProjectAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_attachments do |t|
      t.string :file
      t.references :task, index: true, references: :gns_project_taskss

      t.timestamps
    end
  end
end
