class AddEndDateToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_projects, :end_date, :datetime
  end
end
