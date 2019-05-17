class AddGenderToGnsEmployeeEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_employee_employees, :gender, :string
  end
end
