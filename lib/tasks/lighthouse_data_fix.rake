# frozen_string_literal: true

namespace :lighthouse_boxes do
  desc "Move the lighthouse boxes to their proper location and delete the rogue labware"
  task move: :environment do |_t|
    ActiveRecord::Base.transaction do
      dodgy_labware = Labware.joins(:location).where("labwares.barcode LIKE 'lw-%'").where("locations.parentage LIKE '%reefer%'")
      dodgy_labware_barcodes = dodgy_labware.map(&:barcode).uniq
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
      dodgy_labware.each(&:delete)

      puts "Done"
    end
  end
end
