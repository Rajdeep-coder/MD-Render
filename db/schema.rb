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

ActiveRecord::Schema[7.1].define(version: 2024_02_01_041231) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

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

  create_table "addresses", force: :cascade do |t|
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "address"
    t.string "city"
    t.string "district"
    t.string "state"
    t.string "pin"
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.integer "address_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "buy_milks", force: :cascade do |t|
    t.float "fat", default: 0.0
    t.float "clr", default: 0.0
    t.float "snf", default: 0.0
    t.float "quntity"
    t.float "amount"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shift"
    t.date "date"
    t.integer "rate_type"
    t.integer "chart_id"
    t.bigint "grade_id"
    t.float "little_rate"
  end

  create_table "chart_rates", force: :cascade do |t|
    t.bigint "chart_id"
    t.float "fat"
    t.float "clr"
    t.float "snf"
    t.float "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "charts", force: :cascade do |t|
    t.bigint "my_dairy_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_accounts", force: :cascade do |t|
    t.float "credit"
    t.float "deposit"
    t.float "balance"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "email"
    t.string "password_digest"
    t.string "address"
    t.bigint "my_dairy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "decode_text"
    t.bigint "sid"
    t.integer "rate_type", default: 0
    t.bigint "grade_id"
    t.bigint "chart_id"
    t.index ["my_dairy_id"], name: "index_customers_on_my_dairy_id"
  end

  create_table "deposit_histories", force: :cascade do |t|
    t.float "amount"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "quntity"
    t.bigint "product_id"
    t.integer "deposit_type"
  end

  create_table "device_tokens", force: :cascade do |t|
    t.string "device_token"
    t.integer "my_dairy_id"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.text "token"
    t.integer "token_type"
    t.bigint "my_dairy_id"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.string "name"
    t.float "rate", default: 0.0
    t.bigint "my_dairy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "my_dairies", force: :cascade do |t|
    t.string "dairy_name"
    t.string "owner_name"
    t.string "phone_number"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp"
    t.float "fate_rate"
    t.bigint "plan_id"
    t.boolean "I_agree_terms_and_conditions_and_privacy_policies"
    t.integer "last_assigned_sid", default: 0
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "notify_type"
    t.integer "customer_id"
    t.integer "my_dairy_id"
    t.boolean "is_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "current_data"
    t.jsonb "previous_data"
    t.string "title_hindi"
    t.string "body_hindi"
  end

  create_table "otps", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "otp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_histories", force: :cascade do |t|
    t.integer "status"
    t.float "amount"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.integer "validity"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "my_dairy_id"
    t.bigint "sid"
  end

  create_table "rechargs", force: :cascade do |t|
    t.bigint "my_dairy_id"
    t.bigint "plan_id"
    t.integer "activated", default: 0
    t.date "expire_date"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sell_milks", force: :cascade do |t|
    t.bigint "my_dairy_id"
    t.float "avg_fat"
    t.float "avg_clr"
    t.float "avg_snf"
    t.float "total_quntity"
    t.float "total_amount"
    t.float "fat"
    t.float "clr"
    t.float "snf"
    t.float "quntity"
    t.float "amount"
    t.float "benifit"
    t.float "weight_lose"
    t.integer "shift"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
