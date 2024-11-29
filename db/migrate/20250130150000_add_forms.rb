class AddForms < ActiveRecord::Migration[7.2]
  def change
    create_table "forms" do |t|
      t.text "name"
      t.text "submission_email"
      t.text "privacy_policy_url"
      t.text "form_slug"
      t.text "support_email"
      t.text "support_phone"
      t.text "support_url"
      t.text "support_url_text"
      t.text "declaration_text"
      t.boolean "question_section_completed", default: false
      t.boolean "declaration_section_completed", default: false
      t.timestamps
      t.references :creator, index: false
      t.text "what_happens_next_markdown"
      t.string "state"
      t.string "payment_url"
      t.string "external_id"
      t.string "submission_type", default: "email", null: false
      t.boolean "share_preview_completed", default: false, null: false
      t.string "s3_bucket_name"
      t.string "s3_bucket_aws_account_id"
      t.string "s3_bucket_region"
      t.index "external_id", unique: true
    end

    create_table "pages" do |t|
      t.text "question_text"
      t.text "hint_text"
      t.text "answer_type"
      t.integer "next_page"
      t.boolean "is_optional", null: false
      t.jsonb "answer_settings"
      t.timestamps
      t.references :form, foreign_key: true
      t.integer "position"
      t.text "page_heading"
      t.text "guidance_markdown"
      t.boolean "is_repeatable", default: false, null: false
    end

    create_table "conditions" do |t|
      t.references :check_page, comment: "The question page this condition looks at to compare answers"
      t.references :routing_page, comment: "The question page at which this conditional route takes place"
      t.references :goto_page, comment: "The question page which this conditions will skip forwards to"
      t.string "answer_value"
      t.timestamps
      t.boolean "skip_to_end", default: false
    end
  end
end
