class CreateGnsProjectLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_logs do |t|
      t.references :project, index: true, references: :gns_project_projects
      t.string :class_name
      t.string :phrase
      t.text :data
      t.text :remark
      t.references :user, index: true, references: :gns_core_users

      t.timestamps
    end
  end
end
