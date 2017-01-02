# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161128021628) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "meals", force: :cascade do |t|
    t.integer  "user_id",                  null: false
    t.string   "description", default: "", null: false
    t.integer  "calories",                 null: false
    t.datetime "occurred_at",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "meals", ["user_id", "occurred_at"], name: "index_meals_on_user_id_and_occurred_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",             default: "email", null: false
    t.string   "uid",                  default: "",      null: false
    t.string   "encrypted_password",   default: "",      null: false
    t.integer  "sign_in_count",        default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "email",                                  null: false
    t.string   "name",                                   null: false
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "daily_calorie_target", default: 1500,    null: false
    t.string   "role",                 default: "basic", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

end
