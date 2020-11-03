# frozen_string_literal: true

require 'csv'

class CsvManifest
  include ActiveModel::Model

  attr_accessor :locations, :labware_prefix, :number_of_labwares, :positions

  def generate_csv
    n = 1
    CSV.generate do |csv|
      csv << ['Box Barcode', 'Plate Barcode', 'Position']
      locations.each do |location|
        number_of_labwares.times do
          csv << if location.type == "UnorderedLocation"
                   [location.barcode, "#{labware_prefix}#{pad_number(n)}"]
                 else
                   [location.barcode, "#{labware_prefix}#{pad_number(n)}", positions[n - 1]].compact
                 end
          n += 1
        end
      end
    end
  end

  def pad_number(num)
    format('%<num>06d', num: num)
  end
end

FactoryBot.define do
  factory :csv_manifest do
    transient do
      locations { create_list(:location, 5) }
      labware_prefix { 'RNA' }
      number_of_labwares { 1 }
    end

    initialize_with { new(locations: locations, labware_prefix: labware_prefix, number_of_labwares: number_of_labwares) }

    skip_create
  end
end
