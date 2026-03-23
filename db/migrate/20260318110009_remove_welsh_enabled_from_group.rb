class RemoveWelshEnabledFromGroup < ActiveRecord::Migration[8.1]
  def change
    remove_column :groups, :welsh_enabled, :boolean, default: false
  end
end
