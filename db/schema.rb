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

ActiveRecord::Schema.define(version: 2021_03_04_150513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.uuid "user_id"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "publish_services", force: :cascade do |t|
    t.string "deployment_environment", null: false
    t.uuid "service_id", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "deployment_environment"], name: "index_publish_services_on_service_id_and_deployment_environment"
    t.index ["service_id", "status", "deployment_environment"], name: "index_publish_services_on_service_status_deployment"
    t.index ["service_id"], name: "index_publish_services_on_service_id"
  end

  create_table "service_configurations", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "deployment_environment", null: false
    t.uuid "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "deployment_environment", "name"], name: "index_service_configurations_on_service_deployment_name"
    t.index ["service_id", "deployment_environment"], name: "index_service_configurations_on_service_id_and_deployment_env"
    t.index ["service_id"], name: "index_service_configurations_on_service_id"
  end

  create_table "submission_settings", force: :cascade do |t|
    t.boolean "send_email", default: false
    t.string "deployment_environment"
    t.uuid "service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id", "deployment_environment"], name: "submission_settings_id_and_environment"
    t.index ["service_id"], name: "index_submission_settings_on_service_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "timezone", default: "London"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "identities", "users"
end
