##
# An Ordered Location is one which has a number of coordinates which can contain pieces of labware
# at defined positions e.g. box.
# Logically it can't have locations as children.
class OrderedLocation < Location
  has_many :coordinates, foreign_key: "location_id"
  has_many :labwares, through: :coordinates

  before_create :populate_coordinates

  def available_coordinates(n)
    [AvailableCoordinates.find(self.coordinates, n)].compact
  end

  def populate_coordinates
    Hash.grid(self.rows, self.columns) do |position, row, column|
      coordinates.build(position: position, row: row, column: column)
    end
  end

end