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

ActiveRecord::Schema[7.0].define(version: 2023_05_11_102334) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "organisations", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_organisations_on_content_id", unique: true
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
    t.string "role", default: "editor"
    t.bigint "organisation_id"
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
  end

  add_foreign_key "users", "organisations"
end
