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

ActiveRecord::Schema[7.1].define(version: 2024_02_07_104336) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["form_id"], name: "index_draft_questions_on_form_id"
    t.index ["user_id"], name: "index_draft_questions_on_user_id"
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

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["govuk_content_id"], name: "index_organisations_on_govuk_content_id", unique: true
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
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
    t.string "role", default: "trial"
    t.bigint "organisation_id"
    t.boolean "has_access", default: true
    t.string "provider"
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

  add_foreign_key "draft_questions", "users"
  add_foreign_key "mou_signatures", "organisations"
  add_foreign_key "mou_signatures", "users"
  add_foreign_key "users", "organisations"
end
