class AddFinishedToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :finished, :boolean, default: false
  end
end
