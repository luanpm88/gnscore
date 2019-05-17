class AddBirthdayToGnsEmployeeEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_employee_employees, :birthday, :datetime
  end
end
