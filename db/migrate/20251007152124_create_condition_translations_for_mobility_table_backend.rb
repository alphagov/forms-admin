class CreateConditionTranslationsForMobilityTableBackend < ActiveRecord::Migration[8.0]
  def change
    create_table :condition_translations do |t|
      # Translated attribute(s)
      t.string :answer_value
      t.text :exit_page_markdown
      t.text :exit_page_heading

      t.string :locale, null: false
      t.references :condition, null: false, foreign_key: true, index: false

      t.timestamps null: false
    end

    add_index :condition_translations, :locale, name: :index_condition_translations_on_locale
    add_index :condition_translations, %i[condition_id locale], name: :index_condition_translations_on_condition_id_and_locale, unique: true
  end
end
