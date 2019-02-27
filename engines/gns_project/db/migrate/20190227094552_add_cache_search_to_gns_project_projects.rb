class AddCacheSearchToGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_projects, :cache_search, :text
  end
end
