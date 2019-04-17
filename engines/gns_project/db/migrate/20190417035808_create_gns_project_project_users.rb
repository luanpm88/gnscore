class CreateGnsProjectProjectUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_project_users do |t|
      t.references :project, index: true, references: :gns_project_projects
      t.references :user, index: true, references: :gns_core_users
      t.text :custom_permissions

      t.timestamps
    end
  end
end
