class AddForms < ActiveRecord::Migration[7.2]
  def change
    create_table "forms", force: :cascade do |t|
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
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "creator_id"
      t.text "what_happens_next_markdown"
      t.string "state"
      t.string "payment_url"
      t.string "external_id"
      t.string "submission_type", default: "email", null: false
      t.boolean "share_preview_completed", default: false, null: false
      t.string "s3_bucket_name"
      t.string "s3_bucket_aws_account_id"
      t.string "s3_bucket_region"
      t.index ["external_id"], name: "index_forms_on_external_id", unique: true
    end

    create_table "pages", force: :cascade do |t|
      t.text "question_text"
      t.text "hint_text"
      t.text "answer_type"
      t.integer "next_page"
      t.boolean "is_optional", null: false
      t.jsonb "answer_settings"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "form_id"
      t.integer "position"
      t.text "page_heading"
      t.text "guidance_markdown"
      t.boolean "is_repeatable", default: false, null: false
      t.index ["form_id"], name: "index_pages_on_form_id"
    end

    create_table "conditions", force: :cascade do |t|
      t.bigint "check_page_id", comment: "The question page this condition looks at to compare answers"
      t.bigint "routing_page_id", comment: "The question page at which this conditional route takes place"
      t.bigint "goto_page_id", comment: "The question page which this conditions will skip forwards to"
      t.string "answer_value"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "skip_to_end", default: false
      t.index ["check_page_id"], name: "index_conditions_on_check_page_id"
      t.index ["goto_page_id"], name: "index_conditions_on_goto_page_id"
      t.index ["routing_page_id"], name: "index_conditions_on_routing_page_id"
    end

    add_foreign_key "pages", "forms"
  end
end
