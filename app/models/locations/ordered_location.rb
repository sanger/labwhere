##
# An Ordered Location is one which has a number of coordinates which can contain pieces of labware
# at defined positions e.g. box.
# Logically it can't have locations as children.
class OrderedLocation < Location
  has_many :coordinates, foreign_key: "location_id"
  has_many :labwares, through: :coordinates

  before_create :populate_coordinates

  def available_coordinates(start_position, number_of_coordinates)
    coordinates.select { |c| c.position >= start_position && c.vacant? }.take(number_of_coordinates)
  end

  def populate_coordinates
    Hash.grid(self.rows, self.columns) do |position, row, column|
      coordinates.build(position: position, row: row, column: column)
    end
  end

end