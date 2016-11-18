class LabwareCollection

  include Enumerable

  attr_reader :location, :labwares, :user
  attr_accessor :original_locations

  def initialize(location, user, labwares)
    @location = location
    @user = user
    @labwares = add_labwares(labwares)
    @original_locations = []
  end

  def push
    labwares.each do |labware|
      model = Labware.find_or_initialize_by_barcode(labware)
      coordinate = set_coordinate(labware)
      original_locations << model.location.name unless model.location.empty?
      if coordinate
        coordinate.fill(model.flush)
      else
        location.labwares << model.flush
      end
      model.create_audit(user)
    end
    self
  end

  def each(&block)
    labwares.each(&block)
  end

  def original_location_names
    original_locations.uniq.join(", ")
  end

  def valid?
    location && user && labwares
  end

private

  def add_labwares(labwares)
    labwares.instance_of?(String) ? labwares.split("\n") : labwares
  end

  def ordered?
    @ordered ||= location.ordered?
  end

  def set_coordinate(labware)
    if labware.kind_of?(Hash) && ordered?
      location.coordinates.find_by_position(labware.permit(:position, :row, :column))
    end
  end

end