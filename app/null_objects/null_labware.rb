# frozen_string_literal: true

# Null object for Labware
class NullLabware
  # barcode will always be empty
  def barcode
    "Empty"
  end

  # null labware will always be empty
  def empty?
    true
  end

  def location
    NullLocation.new
  end

  def defined?; true end

  def ==(o)
    o.class == self.class && o.state == self.state
  end

  protected

  def state
    [barcode, location]
  end
end
