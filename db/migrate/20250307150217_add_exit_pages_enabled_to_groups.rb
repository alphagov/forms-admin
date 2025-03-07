class AddExitPagesEnabledToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :exit_pages_enabled, :boolean, default: false
  end
end
