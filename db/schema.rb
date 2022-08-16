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

ActiveRecord::Schema[7.0].define(version: 2022_07_13_111847) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forms", id: :bigint, default: nil, force: :cascade do |t|
    t.text "name"
    t.text "submission_email"
    t.text "org"
  end

  create_table "pages", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "form_id"
    t.text "question_text"
    t.text "question_short_name"
    t.text "hint_text"
    t.text "answer_type"
    t.text "next"
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
  end

  add_foreign_key "pages", "forms", name: "pages_form_id_fkey"
end
