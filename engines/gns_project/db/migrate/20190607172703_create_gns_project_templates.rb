class CreateGnsProjectTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_templates do |t|
      t.string :name
      t.references :category, index: true, references: :gns_project_categories
      t.text :description
      t.references :creator, index: true, references: :gns_core_users
      t.text :cache_search

      t.timestamps
    end
  end
end
