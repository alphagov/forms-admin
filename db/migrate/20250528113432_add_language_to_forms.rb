class AddLanguageToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :language, :string, default: "en", null: false
  end
end
