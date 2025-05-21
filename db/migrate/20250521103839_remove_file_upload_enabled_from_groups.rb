class RemoveFileUploadEnabledFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :file_upload_enabled, :boolean
  end
end
