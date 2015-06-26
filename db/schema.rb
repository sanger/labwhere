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

ActiveRecord::Schema.define(version: 20150626081430) do

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.string   "action"
    t.text     "record_data"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "audits", ["auditable_id", "auditable_type"], name: "index_audits_on_auditable_id_and_auditable_type"
  add_index "audits", ["auditable_type"], name: "index_audits_on_auditable_type"
  add_index "audits", ["user_id"], name: "index_audits_on_user_id"

  create_table "coordinates", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "histories", force: :cascade do |t|
    t.integer  "scan_id"
    t.integer  "labware_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "histories", ["labware_id"], name: "index_histories_on_labware_id"
  add_index "histories", ["scan_id"], name: "index_histories_on_scan_id"

  create_table "labwares", force: :cascade do |t|
    t.string   "barcode"
    t.datetime "deleted_at"
    t.integer  "histories_count",      default: 0
    t.integer  "location_id"
    t.integer  "previous_location_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "coordinate_id"
  end

  add_index "labwares", ["coordinate_id"], name: "index_labwares_on_coordinate_id"
  add_index "labwares", ["location_id"], name: "index_labwares_on_location_id"
  add_index "labwares", ["previous_location_id"], name: "index_labwares_on_previous_location_id"

  create_table "location_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "locations_count", default: 0
    t.integer  "audits_count",    default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "barcode"
    t.integer  "parent_id"
    t.boolean  "container",        default: true
    t.integer  "status",           default: 0
    t.datetime "deactivated_at"
    t.integer  "labwares_count",   default: 0
    t.integer  "audits_count",     default: 0
    t.integer  "location_type_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "parentage"
  end

  add_index "locations", ["location_type_id"], name: "index_locations_on_location_type_id"

  create_table "printers", force: :cascade do |t|
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "audits_count", default: 0
  end

  create_table "scans", force: :cascade do |t|
    t.integer  "status",      default: 0
    t.integer  "location_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "scans", ["location_id"], name: "index_scans_on_location_id"
  add_index "scans", ["user_id"], name: "index_scans_on_user_id"

  create_table "searches", force: :cascade do |t|
    t.string   "term"
    t.integer  "search_count", default: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.integer  "audits_count", default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login"
    t.string   "swipe_card_id"
    t.string   "barcode"
    t.string   "type"
    t.integer  "status",         default: 0
    t.integer  "audits_count",   default: 0
    t.datetime "deactivated_at"
    t.integer  "team_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "users", ["team_id"], name: "index_users_on_team_id"

end
