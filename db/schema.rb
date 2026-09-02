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

ActiveRecord::Schema[8.1].define(version: 2026_09_02_111853) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "random_wants", force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_statuses", force: :cascade do |t|
    t.integer "action_count", default: 0, null: false
    t.integer "action_streak", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "experimence", default: 0, null: false
    t.date "last_action_date"
    t.date "last_login_date", default: -> { "CURRENT_DATE" }, null: false
    t.integer "level", default: 1, null: false
    t.integer "login_count", default: 1, null: false
    t.integer "login_streak", default: 1, null: false
    t.integer "longest_action_streak", default: 0, null: false
    t.integer "longest_login_streak", default: 1, null: false
    t.integer "random_gacha_count", default: 0, null: false
    t.date "random_gacha_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_statuses_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wants", force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.datetime "due_date"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_wants_on_user_id"
  end

  add_foreign_key "user_statuses", "users"
  add_foreign_key "wants", "users"
end
