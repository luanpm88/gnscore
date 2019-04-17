class CreateGnsProjectProjectUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_project_user_roles do |t|
      t.references :project_user, index: true, references: :gns_project_project_users
      t.references :role, index: true, references: :gns_project_roles

      t.timestamps
    end
  end
end
