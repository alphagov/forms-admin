class AddSuperAdminUserToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :super_admin_user, :boolean, default: false
  end
end
