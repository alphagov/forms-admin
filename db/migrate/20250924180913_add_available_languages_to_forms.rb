class AddAvailableLanguagesToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :available_languages, :text, array: true, default: %w[en], null: false
  end
end
