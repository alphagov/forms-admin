class AddLastSignedInAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :last_signed_in_at, :datetime
  end
end
