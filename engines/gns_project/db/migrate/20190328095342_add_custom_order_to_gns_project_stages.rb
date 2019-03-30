class AddCustomOrderToGnsProjectStages < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_stages, :custom_order, :integer
  end
end
