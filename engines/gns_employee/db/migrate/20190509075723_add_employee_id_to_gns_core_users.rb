class AddEmployeeIdToGnsCoreUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_core_users, :employee, index: { unique: true }, references: :gns_employee_employees
  end
end
