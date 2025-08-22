class CreateFormDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :form_documents do |t|
      t.references :form, foreign_key: true, comment: "The form this document belongs to"
      t.text :tag, null: false,  comment: "The tag for the form, for example: 'live' or 'draft'"
      t.jsonb :content, comment: "The JSON which describes the form"

      t.timestamps

      t.index %i[form_id tag], unique: true, name: "index_form_documents_on_form_id_and_tag"
    end
  end
end
