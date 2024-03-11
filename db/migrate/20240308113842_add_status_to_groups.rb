class AddStatusToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :status, :string, default: "trial"
  end
end
