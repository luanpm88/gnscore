class AddStartDateToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_projects, :start_date, :datetime
  end
end
