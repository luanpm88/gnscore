class AddCustomOrderToGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_tasks, :custom_order, :integer
  end
end
