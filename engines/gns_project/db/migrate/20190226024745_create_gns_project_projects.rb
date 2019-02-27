class CreateGnsProjectProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_projects do |t|
      t.string :code
      t.string :name
      t.references :category, index: true, references: :gns_project_categories
      
      t.timestamps
    end
  end
end
