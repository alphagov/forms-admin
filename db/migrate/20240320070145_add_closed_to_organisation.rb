class AddClosedToOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :closed, :boolean, default: false
  end
end
