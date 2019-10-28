# frozen_string_literal: true

module Cgap
  class MigrateLabwares
    def self.run!(path = "lib/cgap/data")
      new(path).run!
    end

    def initialize(path)
      Cgap::LoadData.new("labwares", path).load!
      @cgap_labwares = Cgap::Labware.all
    end

    def run!
      cgap_labwares.each do |cgap_labware|
        location = ::Location.find(cgap_labware.cgap_location.labwhere_id)
        labware = ::Labware.new(barcode: cgap_labware.barcode)
        if cgap_labware.row > 0 && cgap_labware.column > 0
          location.coordinates.find_by_position(row: cgap_labware.row, column: cgap_labware.column).fill(labware)
        else
          location.labwares << labware
        end
      end
    end

    private

    attr_reader :cgap_labwares
  end
end
