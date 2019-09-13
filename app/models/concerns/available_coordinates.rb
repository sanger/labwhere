##
# Find a consecutive list of available coordinates in a set of coordinates signified by n.
# e.g. find 10 consecutive coordinates.
#
class AvailableCoordinates

  # The set of coordinates to check
  attr_reader :coordinates

  # The number of free coordinates needed
  attr_reader :n

  def self.find(*args)
    new(*args).find
  end

  # Order the coordinates
  def initialize(coordinates, n)
    @coordinates = coordinates.ordered
    @n = n
  end

  ##
  # Check each coordinate. If it is empty then check if the next n coordinates are empty.
  # If we can find n empty coordinates then return the coordinates location
  def find
    coordinates.each do |coordinate|
      if coordinate.vacant?
        line = line(coordinate.position, coordinate.position+(n-1))
        return coordinate.location if available?(line) && line.length == n
      end
    end
    nil
  end

private

  def available?(coordinates)
    coordinates.all? { |c| c.vacant? }
  end

  def line(min, max)
    coordinates.select { |c| c.position >= min && c.position <= max}
  end
  
end