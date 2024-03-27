class AddRoleToMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :memberships, :role, :string, default: "editor"
  end
end
