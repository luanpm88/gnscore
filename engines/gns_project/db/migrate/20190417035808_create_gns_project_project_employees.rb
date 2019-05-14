class CreateGnsProjectProjectEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_project_employees do |t|
      t.references :project, index: true, references: :gns_project_projects
      t.references :employee, index: true, references: :gns_employee_employees
      t.text :custom_permissions

      t.timestamps
    end
  end
end
