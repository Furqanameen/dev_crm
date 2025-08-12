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

ActiveRecord::Schema[8.0].define(version: 2025_08_11_231433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

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

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "action", null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["subject_type", "subject_id"], name: "index_audit_logs_on_subject_type_and_subject_id"
  end

  create_table "campaign_recipients", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "campaign_id"
    t.integer "state", default: 0
    t.string "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "campaign_id"], name: "index_campaign_recipients_on_contact_id_and_campaign_id", unique: true
    t.index ["contact_id"], name: "index_campaign_recipients_on_contact_id"
    t.index ["state"], name: "index_campaign_recipients_on_state"
  end

  create_table "contact_list_memberships", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "list_id"], name: "index_contact_list_memberships_on_contact_id_and_list_id", unique: true
    t.index ["contact_id"], name: "index_contact_list_memberships_on_contact_id"
    t.index ["list_id"], name: "index_contact_list_memberships_on_list_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.citext "email"
    t.string "mobile_number"
    t.integer "account_type", default: 0
    t.string "full_name"
    t.string "company_name"
    t.string "role"
    t.string "country"
    t.string "city"
    t.string "source"
    t.jsonb "custom_fields", default: {}
    t.string "tags", default: [], array: true
    t.integer "consent_status", default: 0
    t.datetime "unsubscribed_at"
    t.boolean "bounced", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index "lower((email)::text)", name: "index_contacts_on_LOWER_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["account_type"], name: "index_contacts_on_account_type"
    t.index ["consent_status"], name: "index_contacts_on_consent_status"
    t.index ["custom_fields"], name: "index_contacts_on_custom_fields", using: :gin
    t.index ["mobile_number"], name: "index_contacts_on_mobile_number", where: "(mobile_number IS NOT NULL)"
    t.index ["tags"], name: "index_contacts_on_tags", using: :gin
  end

  create_table "import_batches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0
    t.string "filename"
    t.string "original_filename"
    t.integer "total_rows", default: 0
    t.integer "imported_count", default: 0
    t.integer "updated_count", default: 0
    t.integer "skipped_count", default: 0
    t.integer "error_count", default: 0
    t.jsonb "options", default: {}
    t.jsonb "column_mapping", default: {}
    t.jsonb "error_log", default: []
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_import_batches_on_created_at"
    t.index ["status"], name: "index_import_batches_on_status"
    t.index ["user_id"], name: "index_import_batches_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "user_id", null: false
    t.integer "contacts_count", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_lists_on_name"
    t.index ["user_id", "name"], name: "index_lists_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "campaign_recipients", "contacts"
  add_foreign_key "contact_list_memberships", "contacts"
  add_foreign_key "contact_list_memberships", "lists"
  add_foreign_key "import_batches", "users"
  add_foreign_key "lists", "users"
end
