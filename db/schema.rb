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

ActiveRecord::Schema[7.1].define(version: 2025_01_04_040032) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "item_ranks", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "tier_list_id", null: false
    t.json "custom_values"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["item_id"], name: "index_item_ranks_on_item_id"
    t.index ["tier_list_id"], name: "index_item_ranks_on_tier_list_id"
    t.index ["user_id"], name: "index_item_ranks_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_associations", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "tier_list_id", null: false
    t.string "association_type"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "tier_list_id"], name: "index_page_associations_on_page_id_and_tier_list_id", unique: true
    t.index ["page_id"], name: "index_page_associations_on_page_id"
    t.index ["tier_list_id"], name: "index_page_associations_on_tier_list_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "parent_id"
    t.integer "created_by"
    t.string "category", default: "general", null: false
    t.text "short_description"
    t.text "about"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_pages_on_created_by"
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "tier_list_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "short_description"
    t.json "custom_fields", default: []
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
    t.index ["created_by_id"], name: "index_tier_list_templates_on_created_by_id"
  end

  create_table "tier_lists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "published"
    t.json "custom_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tier_list_template_id"
    t.index ["tier_list_template_id"], name: "index_tier_lists_on_tier_list_template_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", default: "", null: false
    t.boolean "admin", default: false
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "item_ranks", "items"
  add_foreign_key "item_ranks", "tier_lists"
  add_foreign_key "item_ranks", "users"
  add_foreign_key "page_associations", "pages"
  add_foreign_key "page_associations", "tier_lists"
  add_foreign_key "tier_lists", "tier_list_templates"
end
