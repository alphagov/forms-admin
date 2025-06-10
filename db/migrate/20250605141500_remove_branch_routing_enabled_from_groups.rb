class RemoveBranchRoutingEnabledFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :branch_routing_enabled, :boolean, default: false
  end
end
