class AddDescriptionToGnsProjectStages < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_stages, :description, :text
  end
end
