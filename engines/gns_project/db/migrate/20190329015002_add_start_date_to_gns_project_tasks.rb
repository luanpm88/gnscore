class AddStartDateToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :start_date, :datetime
  end
end
