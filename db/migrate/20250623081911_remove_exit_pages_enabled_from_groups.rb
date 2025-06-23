class RemoveExitPagesEnabledFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :exit_pages_enabled, :boolean, default: false
  end
end
