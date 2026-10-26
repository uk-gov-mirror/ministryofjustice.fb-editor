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

ActiveRecord::Schema[8.1].define(version: 2026_10_26_133611) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "admin_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.uuid "service_id"
    t.uuid "user_id"
    t.index ["service_id"], name: "index_admin_events_on_service_id"
    t.index ["user_id"], name: "index_admin_events_on_user_id"
  end

  create_table "announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "date_from", null: false
    t.date "date_to"
    t.datetime "revoked_at"
    t.uuid "revoked_by_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
    t.index ["revoked_by_id"], name: "index_announcements_on_revoked_by_id"
  end

  create_table "announcements_users", id: false, force: :cascade do |t|
    t.uuid "announcement_id", null: false
    t.uuid "user_id", null: false
    t.index ["announcement_id", "user_id"], name: "index_announcements_users_on_announcement_id_and_user_id", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "from_addresses", comment: "DEPRECATED: We have kept the table to ensure backwards compatibility.", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.uuid "service_id", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_from_addresses_on_service_id"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.uuid "user_id"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "publish_services", force: :cascade do |t|
    t.uuid "autocomplete_ids", default: [], array: true
    t.datetime "created_at", null: false
    t.string "deployment_environment", null: false
    t.uuid "service_id", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.uuid "version_id"
    t.index ["service_id", "deployment_environment"], name: "index_publish_services_on_service_id_and_deployment_environment"
    t.index ["service_id", "status", "deployment_environment"], name: "index_publish_services_on_service_status_deployment"
    t.index ["service_id"], name: "index_publish_services_on_service_id"
    t.index ["user_id"], name: "index_publish_services_on_user_id"
  end

  create_table "service_configurations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "deployment_environment", null: false
    t.string "name", null: false
    t.uuid "service_id"
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["service_id", "deployment_environment", "name"], name: "index_service_configurations_on_service_deployment_name"
    t.index ["service_id", "deployment_environment"], name: "index_service_configurations_on_service_id_and_deployment_env"
    t.index ["service_id"], name: "index_service_configurations_on_service_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "submission_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "deployment_environment"
    t.boolean "payment_link", default: false
    t.boolean "send_confirmation_email", default: false
    t.boolean "send_email", default: false
    t.boolean "send_to_graph_api"
    t.boolean "service_csv_output", default: false
    t.uuid "service_id"
    t.datetime "updated_at", null: false
    t.index ["service_id", "deployment_environment"], name: "submission_settings_id_and_environment"
    t.index ["service_id"], name: "index_submission_settings_on_service_id"
  end

  create_table "uptime_checks", force: :cascade do |t|
    t.string "check_id", null: false
    t.datetime "created_at", null: false
    t.uuid "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_uptime_checks_on_service_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "timezone", default: "London"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "announcements", "users", column: "created_by_id"
  add_foreign_key "announcements", "users", column: "revoked_by_id"
  add_foreign_key "identities", "users"
end
