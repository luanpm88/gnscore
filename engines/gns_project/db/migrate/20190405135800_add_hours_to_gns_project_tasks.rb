class AddHoursToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :hours, :float
  end
end
