 # Null object for a coordinate
 class NullCoordinate

  # Always set the name to null
  def name
    "null"
  end

  # Set the location to location unknown
  def location
    Location.unknown
  end

  # A null location will always be empty
  def empty?
    true
  end

  def flush
  end
end