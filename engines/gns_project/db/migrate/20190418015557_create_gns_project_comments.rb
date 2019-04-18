class CreateGnsProjectComments < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_comments do |t|
      t.text :message
      t.string :file
      t.integer :parent_id
      t.references :project, index: true, references: :erp_project_projects
      t.references :user, index: true, references: :erp_core_users

      t.timestamps
    end
  end
end
