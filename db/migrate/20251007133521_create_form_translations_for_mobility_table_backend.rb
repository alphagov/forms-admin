class CreateFormTranslationsForMobilityTableBackend < ActiveRecord::Migration[8.0]
  def change
    create_table :form_translations do |t|
      # Translated attribute(s)
      t.text :name
      t.text :privacy_policy_url
      t.text :support_email
      t.text :support_phone
      t.text :support_url
      t.text :support_url_text
      t.text :declaration_text
      t.text :what_happens_next_markdown
      t.string :payment_url

      t.string :locale, null: false
      t.references :form, null: false, foreign_key: true, index: false

      t.timestamps null: false
    end

    add_index :form_translations, :locale, name: :index_form_translations_on_locale
    add_index :form_translations, %i[form_id locale], name: :index_form_translations_on_form_id_and_locale, unique: true
  end
end
