# frozen_string_literal: true

namespace :lighthouse_boxes do
  desc "Move the lighthouse boxes to their proper location and delete the rogue labware"
  task move: :environment do |_t|
    dodgy_labware = Labware.joins(:location).where("labwares.barcode LIKE 'lw-%'").where("locations.parentage LIKE '%reefer%'")
    dodgy_labware_barcodes = dodgy_labware.map { |lw| lw.barcode }.uniq
    puts "Labwares to remove: #{dodgy_labware_barcodes}"
    puts "Number labwares to remove: #{dodgy_labware_barcodes.count}"

    barcode_to_destination_location_id = dodgy_labware.each_with_object({}) do |lw, object|
      object[lw.barcode] = lw.location_id
    end
    puts "Box barcode to desired location: #{barcode_to_destination_location_id}"

    locs_to_move = Location.where(barcode: dodgy_labware_barcodes)
    puts "Locations (boxes) to move: #{locs_to_move.map(&:name)}"
    puts "Number locations to move: #{locs_to_move.count}"

    puts "Moving locations..."
    locs_to_move.each { |loc| loc.update!(parent_id: barcode_to_destination_location_id[loc.barcode]) }

    puts "Deleting labwares..."
    dodgy_labware.each { |lw| lw.delete }

    puts "Done"
  end
end


# # *********** A script to test the above task: **************
# # Create a Lighthouse box, with a plate in it
# box = UnorderedLocation.create!(name: 'box 1', location_type: LocationType.first, parent: Location.first)
# plate = Labware.create!(barcode: 'plate_1', location: box)

# # Create a shelf in a reefer, to where we want to move the box
# reefer = Location.create!(name: 'reefer 1', location_type: LocationType.first, parent: Location.find(2))
# shelf = Location.create!(name: 'shelf 1', location_type: LocationType.first, parent: reefer)
# # Create a labware, which we accidentally created when we tried to move the box previously
# box_labware = Labware.create!(barcode: box.barcode, location: shelf)

# # Run script here

# # Check that box still contains plate
# box.labwares.count # should be 1
# box.labwares.first.barcode # should be 'plate_1'

# # Check that reefer contains box
# shelf.children.count # should be 1
# shelf.children.first.barcode # should be box.barcode

# # Check that box_labware was deleted
# Labware.find_by(barcode: box.barcode) # should return nothing