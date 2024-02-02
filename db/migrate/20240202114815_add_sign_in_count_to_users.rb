class AddSignInCountToUsers < ActiveRecord::Migration[7.1]
  class StubedUser < ApplicationRecord
    self.table_name = "users"
  end

  def change
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    StubedUser.update_all(sign_in_count: 1)
  end
end
