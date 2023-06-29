class UpdateDefaultValueForUserRole < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :role, from: "editor", to: "trial"
  end
end
