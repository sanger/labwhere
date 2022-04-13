# frozen_string_literal: true

class NullLabwareCollection
  def count
    0
  end

  def labwares
    [NullLabware.new]
  end

  def location
    NullLocation.new
  end

  def original_locations
    []
  end

  def original_location_names
    ''
  end
end
