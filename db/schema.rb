# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_08_155727) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conditions", force: :cascade do |t|
    t.bigint "check_page_id", comment: "The question page this condition looks at to compare answers"
    t.bigint "routing_page_id", comment: "The question page at which this conditional route takes place"
    t.bigint "goto_page_id", comment: "The question page which this conditions will skip forwards to"
    t.string "answer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "skip_to_end", default: false
    t.text "exit_page_markdown", comment: "When not nil this condition should be treated as an exit page. When set it contains the markdown for the body of the exit page"
    t.text "exit_page_heading", comment: "Text for the heading of the exit page"
    t.index ["check_page_id"], name: "index_conditions_on_check_page_id"
    t.index ["goto_page_id"], name: "index_conditions_on_goto_page_id"
    t.index ["routing_page_id"], name: "index_conditions_on_routing_page_id"
  end

  create_table "create_form_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.string "form_name", null: false
    t.bigint "form_id"
    t.integer "dedup_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "form_name", "dedup_version"], name: "idx_on_group_id_form_name_dedup_version_9b12b4ae60", unique: true
    t.index ["group_id"], name: "index_create_form_events_on_group_id"
    t.index ["user_id"], name: "index_create_form_events_on_user_id"
  end

  create_table "draft_questions", force: :cascade do |t|
    t.integer "form_id"
    t.bigint "user_id", null: false
    t.integer "page_id"
    t.text "answer_type"
    t.text "question_text"
    t.text "hint_text"
    t.boolean "is_optional"
    t.text "page_heading"
    t.text "guidance_markdown"
    t.jsonb "answer_settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_repeatable"
    t.index ["form_id"], name: "index_draft_questions_on_form_id"
    t.index ["user_id"], name: "index_draft_questions_on_user_id"
  end

  create_table "form_documents", force: :cascade do |t|
    t.bigint "form_id", comment: "The form this document belongs to"
    t.text "tag", null: false, comment: "The tag for the form, for example: 'live' or 'draft'"
    t.jsonb "content", comment: "The JSON which describes the form"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "tag"], name: "index_form_documents_on_form_id_and_tag", unique: true
    t.index ["form_id"], name: "index_form_documents_on_form_id"
  end

  create_table "form_submission_emails", force: :cascade do |t|
    t.integer "form_id"
    t.string "temporary_submission_email"
    t.string "confirmation_code"
    t.string "created_by_name"
    t.string "created_by_email"
    t.string "updated_by_name"
    t.string "updated_by_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_form_submission_emails_on_form_id"
  end

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
    t.string "language", default: "en", null: false
    t.index ["external_id"], name: "index_forms_on_external_id", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "external_id", null: false
    t.bigint "organisation_id"
    t.string "status", default: "trial"
    t.bigint "creator_id"
    t.bigint "upgrade_requester_id"
    t.boolean "welsh_enabled", default: false
    t.index ["creator_id"], name: "index_groups_on_creator_id"
    t.index ["external_id"], name: "index_groups_on_external_id", unique: true
    t.index ["name", "organisation_id"], name: "index_groups_on_name_and_organisation_id", unique: true
    t.index ["organisation_id"], name: "index_groups_on_organisation_id"
    t.index ["upgrade_requester_id"], name: "index_groups_on_upgrade_requester_id"
  end

  create_table "groups_form_ids", id: false, force: :cascade do |t|
    t.bigint "form_id", null: false
    t.bigint "group_id", null: false
    t.index ["form_id"], name: "index_groups_form_ids_on_form_id", unique: true
    t.index ["group_id"], name: "index_groups_form_ids_on_group_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "The user who is a member of the group"
    t.bigint "group_id", null: false, comment: "The group that the user is a member of"
    t.bigint "added_by_id", null: false, comment: "The user who created the membership"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "editor"
    t.index ["added_by_id"], name: "index_memberships_on_added_by_id"
    t.index ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, comment: "Ensure that a user can only be a member of a group once"
  end

  create_table "mou_signatures", comment: "User signatures of a memorandum of understanding (MOU) for an organisation", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "User who signed MOU"
    t.bigint "organisation_id", comment: "Organisation which user signed MOU on behalf of, or null"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_mou_signatures_on_organisation_id"
    t.index ["user_id", "organisation_id"], name: "index_mou_signatures_on_user_id_and_organisation_id", unique: true, comment: "Users can only sign an MOU for an Organisation once"
    t.index ["user_id"], name: "index_mou_signatures_on_user_id"
    t.index ["user_id"], name: "index_mou_signatures_on_user_id_unique_without_organisation_id", unique: true, where: "(organisation_id IS NULL)", comment: "Users can only sign a single MOU without an organisation"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "govuk_content_id"
    t.string "slug", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed", default: false
    t.string "abbreviation"
    t.boolean "internal", default: false
    t.index ["govuk_content_id"], name: "index_organisations_on_govuk_content_id", unique: true
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.text "question_text"
    t.text "hint_text"
    t.text "answer_type"
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

  create_table "schema_info", id: false, force: :cascade do |t|
    t.integer "version", default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.string "app_name"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "standard"
    t.bigint "organisation_id"
    t.boolean "has_access", default: true
    t.string "provider"
    t.datetime "terms_agreed_at"
    t.datetime "last_signed_in_at"
    t.string "research_contact_status", default: "to_be_asked"
    t.datetime "user_research_opted_in_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "create_form_events", "groups", on_delete: :cascade
  add_foreign_key "create_form_events", "users", on_delete: :cascade
  add_foreign_key "draft_questions", "users"
  add_foreign_key "form_documents", "forms"
  add_foreign_key "groups", "users", column: "creator_id"
  add_foreign_key "groups", "users", column: "upgrade_requester_id"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "memberships", "users", column: "added_by_id"
  add_foreign_key "mou_signatures", "organisations"
  add_foreign_key "mou_signatures", "users"
  add_foreign_key "pages", "forms"
  add_foreign_key "users", "organisations"
end
