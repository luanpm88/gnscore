class AddFileInfosToGnsProjectAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :gns_project_attachments, :extension, :string
    add_column :gns_project_attachments, :size, :float
    add_column :gns_project_attachments, :original_name, :string
    add_column :gns_project_attachments, :uploaded_at, :datetime
  end
end
