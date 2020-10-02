# frozen_string_literal: true

##
# An Ordered Location is one which has a number of coordinates which can contain pieces of labware
# at defined positions e.g. box.
# Logically it can't have locations as children.
class OrderedLocation < Location
  has_many :coordinates, foreign_key: "location_id"
  has_many :labwares, through: :coordinates do
    # Rails does not provide a functional delete_all for has_many through associations
    # Here we define our own version, which detaches the labware from their coordinates
    # We use update_all, which like delete_all, avoids instantiating the records, or
    # firing callbacks. This allows the operation to proceed quickly.
    # We reset the association afterwards to ensure it doesn't continue to
    # report labware if accessed again.
    def delete_all
      update_all(coordinate_id: nil)
      reset
    end
  end

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
