class RemoveLongListsEnabledFromGroups < ActiveRecord::Migration[7.2]
  def change
    remove_column :groups, :long_lists_enabled, :boolean
  end
end
