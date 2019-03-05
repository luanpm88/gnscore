class CreateGnsProjectStages < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_stages do |t|
      t.string :name
      t.references :category, index: true, references: :gns_project_categories

      t.timestamps
    end
  end
end
