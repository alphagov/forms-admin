class AddDeclarationMarkdownToFormAndFormTranslation < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :declaration_markdown, :text
    add_column :form_translations, :declaration_markdown, :text
  end
end
