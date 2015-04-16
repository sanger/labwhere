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

ActiveRecord::Schema.define(version: 20150416081715) do

  create_table "events", force: :cascade do |t|
    t.integer  "scan_id"
    t.integer  "labware_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "events", ["labware_id"], name: "index_events_on_labware_id"
  add_index "events", ["scan_id"], name: "index_events_on_scan_id"

  create_table "labwares", force: :cascade do |t|
    t.string   "barcode"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
  end

  add_index "labwares", ["location_id"], name: "index_labwares_on_location_id"

  create_table "location_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "barcode"
    t.integer  "parent_id"
    t.boolean  "container"
    t.boolean  "active",           default: true
    t.integer  "location_type_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "deactivated_at"
  end

  add_index "locations", ["location_type_id"], name: "index_locations_on_location_type_id"

  create_table "scans", force: :cascade do |t|
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "scans", ["location_id"], name: "index_scans_on_location_id"

end
