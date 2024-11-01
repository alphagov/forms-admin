class AddLongListsEnabledToGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :long_lists_enabled, :boolean, default: false
  end
end
