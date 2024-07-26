class UpdateDefaultValueForUserRoleToStandard < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :role, from: "trial", to: "standard"
  end
end
