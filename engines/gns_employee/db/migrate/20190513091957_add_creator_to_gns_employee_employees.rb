class AddCreatorToGnsEmployeeEmployees < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_employee_employees, :creator, index: true, references: :gns_employee_employees
  end
end
