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

ActiveRecord::Schema.define(version: 20160228195921) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "address"
    t.integer  "city_id"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "address_2"
  end

  add_index "addresses", ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree
  add_index "addresses", ["city_id"], name: "index_addresses_on_city_id", using: :btree

  create_table "cart_items", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "quantity"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "price_cents",    default: 0,          null: false
    t.string   "price_currency", default: "USD",      null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "delivery_time",  default: "11:30 AM"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "menu_products", force: :cascade do |t|
    t.integer "menu_id"
    t.integer "product_id"
  end

  add_index "menu_products", ["menu_id"], name: "index_menu_products_on_menu_id", using: :btree
  add_index "menu_products", ["product_id"], name: "index_menu_products_on_product_id", using: :btree

  create_table "menus", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "region_id"
  end

  add_index "menus", ["date", "region_id"], name: "index_menus_on_date_and_region_id", unique: true, using: :btree
  add_index "menus", ["region_id"], name: "index_menus_on_region_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "amount_cents",     default: 0,     null: false
    t.string   "amount_currency",  default: "USD", null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "delivery_address"
    t.string   "charge_id"
    t.string   "refund_id"
    t.text     "observations"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "USD", null: false
    t.string   "image"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "description"
    t.string   "restaurant"
  end

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "customer_id"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
    t.integer  "current_address_id"
    t.string   "mobile_number"
    t.string   "avatar"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  add_foreign_key "addresses", "cities"
  add_foreign_key "carts", "users"
  add_foreign_key "menu_products", "menus"
  add_foreign_key "menu_products", "products"
  add_foreign_key "menus", "regions"
  add_foreign_key "orders", "users"
end
