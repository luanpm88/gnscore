class CreateGnsProjectProjectEmployeeRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_project_employee_roles do |t|
      t.references :project_employee, index: true, references: :gns_project_project_employees
      t.references :role, index: true, references: :gns_project_roles

      t.timestamps
    end
  end
end
