class AddHasAccessToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :has_access, :boolean, default: true
  end
end
