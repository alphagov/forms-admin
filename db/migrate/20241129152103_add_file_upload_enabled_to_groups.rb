class AddFileUploadEnabledToGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :file_upload_enabled, :boolean, default: false
  end
end
