class AddEndDateToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :end_date, :datetime
  end
end
