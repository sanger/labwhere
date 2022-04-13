# frozen_string_literal: true

# Null object for a coordinate
class NullCoordinate
  # Always set the name to null
  def name
    'null'
  end

  # Set the location to location unknown
  def location
    NullLocation.new
  end

  # A null location will always be empty
  def vacant?
    true
  end

  def flush
  end

  def row
  end

  def column
  end

  def position
  end

  def marked_for_destruction?
    false
  end
end
