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

ActiveRecord::Schema.define(version: 2021_03_03_135315) do

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "auditable_type"
    t.integer "auditable_id"
    t.string "action"
    t.text "record_data"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Audit. Added to send to Events Warehouse."
    t.text "message"
    t.index ["auditable_id", "auditable_type"], name: "index_audits_on_auditable_id_and_auditable_type"
    t.index ["auditable_type"], name: "index_audits_on_auditable_type"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "coordinates", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "position"
    t.integer "row"
    t.integer "column"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_coordinates_on_location_id"
  end

  create_table "labwares", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "barcode"
    t.datetime "deleted_at"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "coordinate_id"
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Labware. Added to send to Events Warehouse. Doesn't match up with Sequencescape or any other app."
    t.index ["barcode"], name: "index_labwares_on_barcode", unique: true
    t.index ["coordinate_id"], name: "index_labwares_on_coordinate_id"
    t.index ["location_id"], name: "index_labwares_on_location_id"
  end

  create_table "location_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_types_restrictions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "location_type_id", null: false
    t.integer "restriction_id", null: false
    t.index ["restriction_id", "location_type_id"], name: "restriction_id_and_location_type_id_index", unique: true
  end

  create_table "locations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "barcode"
    t.string "parentage"
    t.string "type"
    t.integer "internal_parent_id"
    t.boolean "container", default: true
    t.integer "status", default: 0
    t.integer "rows", default: 0
    t.integer "columns", default: 0
    t.datetime "deactivated_at"
    t.integer "location_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.string "ancestry"
    t.integer "children_count", default: 0, null: false
    t.string "uuid", limit: 36, null: false, comment: "Unique identifier for this Location. Added to send to Events Warehouse."
    t.boolean "protected", default: false
    t.index ["ancestry"], name: "index_locations_on_ancestry"
    t.index ["barcode"], name: "index_locations_on_barcode", unique: true
    t.index ["location_type_id"], name: "index_locations_on_location_type_id"
    t.index ["team_id"], name: "index_locations_on_team_id"
  end

  create_table "printers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restrictions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "type"
    t.string "validator"
    t.text "params"
    t.integer "location_type_id"
    t.index ["location_type_id"], name: "index_restrictions_on_location_type_id"
  end

  create_table "scans", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "message"
    t.integer "location_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "start_position"
    t.index ["location_id"], name: "index_scans_on_location_id"
    t.index ["user_id"], name: "index_scans_on_user_id"
  end

  create_table "searches", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "term"
    t.integer "search_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "login"
    t.string "swipe_card_id"
    t.string "barcode"
    t.string "type"
    t.integer "status", default: 0
    t.datetime "deactivated_at"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_users_on_team_id"
  end

end
