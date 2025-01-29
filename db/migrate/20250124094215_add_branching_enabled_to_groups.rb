class AddBranchingEnabledToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :branch_routing_enabled, :boolean, default: false
  end
end
