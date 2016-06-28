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

ActiveRecord::Schema.define(version: 20160622130259) do

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
    t.integer  "position"
    t.integer  "row"
    t.integer  "column"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "coordinates", ["location_id"], name: "index_coordinates_on_location_id"

  create_table "labwares", force: :cascade do |t|
    t.string   "barcode"
    t.datetime "deleted_at"
    t.integer  "location_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "coordinate_id"
  end

  add_index "labwares", ["coordinate_id"], name: "index_labwares_on_coordinate_id"
  add_index "labwares", ["location_id"], name: "index_labwares_on_location_id"

  create_table "location_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "barcode"
    t.string   "parentage"
    t.string   "type"
    t.integer  "parent_id"
    t.boolean  "container",        default: true
    t.integer  "status",           default: 0
    t.integer  "rows",             default: 0
    t.integer  "columns",          default: 0
    t.datetime "deactivated_at"
    t.integer  "location_type_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "team_id"
  end

  add_index "locations", ["location_type_id"], name: "index_locations_on_location_type_id"
  add_index "locations", ["team_id"], name: "index_locations_on_team_id"

  create_table "printers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scans", force: :cascade do |t|
    t.integer  "status",      default: 0
    t.string   "message"
    t.integer  "location_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "scans", ["location_id"], name: "index_scans_on_location_id"
  add_index "scans", ["user_id"], name: "index_scans_on_user_id"

  create_table "searches", force: :cascade do |t|
    t.string   "term"
    t.integer  "search_count", default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login"
    t.string   "swipe_card_id"
    t.string   "barcode"
    t.string   "type"
    t.integer  "status",         default: 0
    t.datetime "deactivated_at"
    t.integer  "team_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "users", ["team_id"], name: "index_users_on_team_id"

end
