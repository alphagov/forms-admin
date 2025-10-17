class CreatePageTranslationsForMobilityTableBackend < ActiveRecord::Migration[8.0]
  def change
    create_table :page_translations do |t|
      # Translated attribute(s)
      t.text :question_text
      t.text :hint_text
      t.jsonb :answer_settings
      t.text :page_heading
      t.text :guidance_markdown

      t.string :locale, null: false
      t.references :page, null: false, foreign_key: true, index: false

      t.timestamps null: false
    end

    add_index :page_translations, :locale, name: :index_page_translations_on_locale
    add_index :page_translations, %i[page_id locale], name: :index_page_translations_on_page_id_and_locale, unique: true
  end
end
