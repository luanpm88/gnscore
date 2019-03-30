class AddStatusToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :status, :string
  end
end
