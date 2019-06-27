class AddTemplateToErpProjectProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_project_projects, :template, index: true, references: :gns_project_templates
  end
end
