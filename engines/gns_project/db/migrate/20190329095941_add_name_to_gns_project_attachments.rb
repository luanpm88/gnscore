class AddNameToGnsProjectAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_attachments, :name, :string
  end
end
