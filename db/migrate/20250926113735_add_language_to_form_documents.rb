class AddLanguageToFormDocuments < ActiveRecord::Migration[8.0]
  # allow algorithm :concurrently when creating the index
  disable_ddl_transaction!

  def up
    add_column :form_documents, :language, :string, null: false, default: "en"

    # remove the old index
    remove_index :form_documents, name: "index_form_documents_on_form_id_and_tag"

    add_index :form_documents, %i[form_id tag language], name: "index_form_documents_on_form_id_tag_and_language", unique: true, algorithm: :concurrently
  end

  def down
    # remove the index added in up
    remove_index :form_documents, name: "index_form_documents_on_form_id_tag_and_language"

    # create the original index
    add_index :form_documents, %i[form_id tag], name: "index_form_documents_on_form_id_and_tag", unique: true, algorithm: :concurrently

    remove_column :form_documents, :language
  end
end
