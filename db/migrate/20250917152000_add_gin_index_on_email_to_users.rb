class AddGinIndexOnEmailToUsers < ActiveRecord::Migration[8.0]
  def up
    add_index :users, "LOWER(email) gin_trgm_ops", using: :gin
  end

  def down
    remove_index :users, "LOWER(email) gin_trgm_ops"
  end
end
