class CreateGnsProjectTemplateDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_project_template_details do |t|
      t.references :template, index: true, references: :gns_project_templates
      t.references :stage, index: true, references: :gns_project_stages
      t.string :task_description
      t.integer :custom_order

      t.timestamps
    end
  end
end
