class AddWelshEnabledToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :welsh_enabled, :boolean, default: false
  end
end
