class AddCreatorToGnsProjectCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :gns_project_categories, :creator, index: true, references: :gns_core_users
  end
end
