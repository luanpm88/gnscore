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

ActiveRecord::Schema.define(version: 2019_03_08_020441) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gns_area_countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
  end

  create_table "gns_area_districts", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
    t.index ["state_id"], name: "index_gns_area_districts_on_state_id"
  end

  create_table "gns_area_states", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
    t.index ["country_id"], name: "index_gns_area_states_on_country_id"
  end

  create_table "gns_contact_categories", force: :cascade do |t|
    t.string "name"
    t.text "cache_search"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gns_contact_categories_contacts", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "contact_id"
    t.index ["category_id"], name: "index_gns_contact_categories_contacts_on_category_id"
    t.index ["contact_id"], name: "index_gns_contact_categories_contacts_on_contact_id"
  end

  create_table "gns_contact_contacts", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
    t.bigint "country_id"
    t.bigint "state_id"
    t.bigint "district_id"
    t.index ["country_id"], name: "index_gns_contact_contacts_on_country_id"
    t.index ["district_id"], name: "index_gns_contact_contacts_on_district_id"
    t.index ["state_id"], name: "index_gns_contact_contacts_on_state_id"
  end

  create_table "gns_contact_parent_contacts", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_gns_contact_parent_contacts_on_contact_id"
    t.index ["parent_id"], name: "index_gns_contact_parent_contacts_on_parent_id"
  end

  create_table "gns_project_attachments", force: :cascade do |t|
    t.string "file"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_gns_project_attachments_on_task_id"
  end

  create_table "gns_project_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
  end

  create_table "gns_project_projects", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cache_search"
    t.bigint "customer_id"
    t.index ["category_id"], name: "index_gns_project_projects_on_category_id"
    t.index ["customer_id"], name: "index_gns_project_projects_on_customer_id"
  end

  create_table "gns_project_stages", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_gns_project_stages_on_category_id"
  end

  create_table "gns_project_tasks", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_gns_project_tasks_on_project_id"
    t.index ["stage_id"], name: "index_gns_project_tasks_on_stage_id"
  end

end
