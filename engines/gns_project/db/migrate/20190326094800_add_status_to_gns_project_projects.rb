class AddStatusToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_projects, :status, :string
  end
end
