class AddProgressToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :progress, :integer, default: 0
  end
end
