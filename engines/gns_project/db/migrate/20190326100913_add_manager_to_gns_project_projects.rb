class AddManagerToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_project_projects, :manager, index: true, references: :gns_employee_employees
  end
end
