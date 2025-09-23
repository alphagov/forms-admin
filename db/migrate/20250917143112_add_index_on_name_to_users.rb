class AddIndexOnNameToUsers < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pg_trgm"

    add_index :users, "LOWER(name) gin_trgm_ops", using: :gin
  end

  def down
    remove_index :users, "LOWER(name) gin_trgm_ops"
    disable_extension "pg_trgm"
  end
end
