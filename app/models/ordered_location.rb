class OrderedLocation < Location
  has_many :coordinates, foreign_key: "location_id"
  has_many :labwares, through: :coordinates

  before_create :populate_coordinates

  def add_labware(attributes)
    return [nil, nil] unless attributes.is_a?(Hash)
    if coordinate = coordinates.find_by_position(attributes.slice(:position, :row, :column))
      labware = Labware.find_or_initialize_by(attributes.slice(:barcode))
      labware_dup = labware.dup
      coordinate.fill(labware)
    end
    [labware, labware_dup]
  end

  def add_labwares(labwares)
    return unless labwares.instance_of?(Array)
    labwares.each do |labware|
      after, before = add_labware(labware)
      if after
        yield(after, before) if block_given?
      end
    end
  end

private

  def populate_coordinates
    Hash.grid(self.rows, self.columns) do |position, row, column|
      coordinates.build(position: position, row: row, column: column)
    end
  end
  
end