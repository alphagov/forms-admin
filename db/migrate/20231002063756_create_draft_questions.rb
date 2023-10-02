class CreateDraftQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :draft_questions do |t|
      t.integer :form_id, index: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :page_id
      t.text :answer_type
      t.text :question_text
      t.text :hint_text
      t.boolean :is_optional
      t.text :page_heading
      t.text :guidance_markdown
      t.jsonb :answer_settings, default: {}

      t.timestamps
    end
  end
end
