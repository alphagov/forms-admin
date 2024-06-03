class AddDefaultGroupToOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_reference :organisations, :default_group, null: true, foreign_key: { to_table: :groups }
  end
end
