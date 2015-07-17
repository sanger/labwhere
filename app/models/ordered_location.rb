class OrderedLocation < Location
  has_many :coordinates, foreign_key: "location_id"
  has_many :labwares, through: :coordinates

  before_create :populate_coordinates

  def add_labware(attributes)
    return unless attributes.is_a?(Hash)
    if coordinate = coordinates.find_by_position(attributes.slice(:position, :row, :column))
      coordinate.fill(Labware.find_or_initialize_by(attributes.slice(:barcode)))
    end
  end

  def add_labwares(labwares)
    return [] unless labwares.instance_of?(Array)
    [].tap do |l|
      labwares.each { |labware| l << add_labware(labware) }
    end.compact
  end

private

  def populate_coordinates
    Hash.grid(self.rows, self.columns) do |position, row, column|
      coordinates.build(position: position, row: row, column: column)
    end
  end
  
end