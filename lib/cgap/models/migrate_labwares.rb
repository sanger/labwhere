class MigrateLabwares
  
  def self.run!(path = "lib/cgap/data")
    new(path).run!
  end 

  def initialize(path)
    LoadData.new("labwares", path).load!
    @cgap_labwares = CgapLabware.all 
  end

  def run!
    cgap_labwares.each do |cgap_labware|
      location = Location.find(cgap_labware.cgap_location.labwhere_id)
      if cgap_labware.row > 0 && cgap_labware.column > 0
        location.add_labware(barcode: cgap_labware.barcode, row: cgap_labware.row, column: cgap_labware.column)
      else
        location.add_labware(cgap_labware.barcode)
      end
    end
  end

private

  attr_reader :cgap_labwares
end