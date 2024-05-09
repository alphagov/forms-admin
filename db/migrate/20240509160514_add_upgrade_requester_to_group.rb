class AddUpgradeRequesterToGroup < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :upgrade_requester, null: true, foreign_key: { to_table: :users }
  end
end
