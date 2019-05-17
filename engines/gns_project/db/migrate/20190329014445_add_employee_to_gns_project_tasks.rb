class AddEmployeeToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_project_tasks, :employee, index: true, references: :gns_employee_employees
  end
end
