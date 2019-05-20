class AddLeavingDateToGnsEmployeeEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_employee_employees, :leaving_date, :datetime
  end
end
