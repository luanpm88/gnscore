class CreateGnsProjectTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_tasks do |t|
      t.string :name
      t.references :project, index: true, references: :gns_project_projects
      t.references :stage, index: true, references: :gns_project_stages

      t.timestamps
    end
  end
end
