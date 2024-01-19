# frozen_string_literal: true

namespace :duplicates do
  desc 'De-duplicate labware'
  task delete: :environment do |_t|
    ActiveRecord::Base.transaction do
      puts 'Starting de-duping...'

      # Get all the barcodes where there are duplicates
      barcode_to_count = Labware.group(:barcode).count

      barcode_to_count_duped = barcode_to_count.select { |_barcode, count| count > 1 } # 7106
      puts "Barcodes with duplicates: #{barcode_to_count_duped.size}"

      labs = Labware.where(barcode: barcode_to_count_duped.keys) # 19,240 (between 2 and 3 times above)
      # of which, created today = 19,233 and before today = 7
      puts "Labware with those barcodes: #{labs.size}"

      barcode_to_labs = labs.group_by(&:barcode)

      puts 'Deleting duplicates...'
      barcode_to_labs.each_value do |labwares|
        # save one of them
        labwares.pop

        # delete the rest
        labwares.each do |lab|
          lab.audits.each(&:destroy)
          lab.delete
        end
      end

      puts 'Finished de-duping.'
    end
  end
end
