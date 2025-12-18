class AddCopyRefToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :copied_from_id, :integer, null: true
  end
end
