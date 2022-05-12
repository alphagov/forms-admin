class AddEmailToForms < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :email, :string
  end
end
