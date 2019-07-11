class AddActiveToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_projects, :active, :boolean, default: true
  end
end
