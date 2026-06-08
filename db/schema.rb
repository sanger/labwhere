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

ActiveRecord::Schema[8.1].define(version: 2026_06_02_000001) do
  create_table "audits", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "action"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.text "message", size: :long
    t.text "record_data", size: :long
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Audit. Added to send to Events Warehouse."
    t.index ["auditable_id", "auditable_type"], name: "index_audits_on_auditable_id_and_auditable_type"
    t.index ["auditable_type"], name: "index_audits_on_auditable_type"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "coordinates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "column"
    t.datetime "created_at", null: false
    t.integer "location_id"
    t.integer "position"
    t.integer "row"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_coordinates_on_location_id"
  end

  create_table "labwares", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "barcode"
    t.integer "coordinate_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "location_id"
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Labware. Added to send to Events Warehouse. Doesn't match up with Sequencescape or any other app."
    t.index ["barcode"], name: "index_labwares_on_barcode", unique: true
    t.index ["coordinate_id"], name: "index_labwares_on_coordinate_id"
    t.index ["location_id"], name: "index_labwares_on_location_id"
  end

  create_table "location_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "location_types_restrictions", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "location_type_id", null: false
    t.integer "restriction_id", null: false
    t.index ["restriction_id", "location_type_id"], name: "restriction_id_and_location_type_id_index", unique: true
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ancestry"
    t.string "barcode"
    t.integer "children_count", default: 0, null: false
    t.integer "columns", default: 0
    t.boolean "container", default: true
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.integer "internal_parent_id"
    t.integer "location_type_id"
    t.string "name"
    t.string "parentage"
    t.boolean "protected", default: false
    t.integer "rows", default: 0
    t.integer "status", default: 0
    t.integer "team_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Location. Added to send to Events Warehouse."
    t.index ["ancestry"], name: "index_locations_on_ancestry"
    t.index ["barcode"], name: "index_locations_on_barcode", unique: true
    t.index ["location_type_id"], name: "index_locations_on_location_type_id"
    t.index ["team_id"], name: "index_locations_on_team_id"
  end

  create_table "printers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "restrictions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "location_type_id"
    t.text "params", size: :long
    t.string "type"
    t.string "validator"
    t.index ["location_type_id"], name: "index_restrictions_on_location_type_id"
  end

  create_table "scans", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "location_id"
    t.string "message"
    t.integer "start_position"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["location_id"], name: "index_scans_on_location_id"
    t.index ["user_id"], name: "index_scans_on_user_id"
  end

  create_table "searches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "search_count", default: 0
    t.string "term"
    t.datetime "updated_at", null: false
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number"
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "barcode"
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "login"
    t.integer "status", default: 0
    t.string "swipe_card_id"
    t.integer "team_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_users_on_team_id"
  end
end
