class AvailableCoordinates

  attr_reader :coordinates, :n

  def initialize(coordinates, n)
    @coordinates = coordinates.ordered
    @n = n
  end

  def result
    coordinates.each do |coordinate|
      if coordinate.empty?
        line = line(coordinate.position, coordinate.position+(n-1))
        return coordinate.location if available?(line) && line.length == n
      end
    end
    nil
  end

private

  def available?(coordinates)
    coordinates.all? { |c| c.empty? }
  end

  def line(min, max)
    coordinates.select { |c| c.position >= min && c.position <= max}
  end
  
end