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

ActiveRecord::Schema[7.2].define(version: 2026_02_11_040858) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "name"], name: "index_categories_on_group_id_and_name", unique: true
    t.index ["group_id"], name: "index_categories_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "invite_token", limit: 24, null: false
    t.boolean "is_guest", default: false, null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_token"], name: "index_groups_on_invite_token", unique: true
    t.index ["is_guest", "expires_at"], name: "index_groups_on_is_guest_and_expires_at"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "item_id"], name: "index_inventories_on_group_id_and_item_id", unique: true
    t.index ["group_id"], name: "index_inventories_on_group_id"
    t.index ["item_id"], name: "index_inventories_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["group_id", "name"], name: "index_items_on_group_id_and_name", unique: true
    t.index ["group_id"], name: "index_items_on_group_id"
  end

  add_foreign_key "categories", "groups", on_delete: :cascade
  add_foreign_key "inventories", "groups", on_delete: :cascade
  add_foreign_key "inventories", "items", on_delete: :cascade
  add_foreign_key "items", "categories", on_delete: :cascade
  add_foreign_key "items", "groups", on_delete: :cascade
end
