class CreateGnsProjectRolesPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_roles_permissions do |t|
      t.references :role, index: true, references: :gns_project_roles
      t.string :permission

      t.timestamps
    end
  end
end
