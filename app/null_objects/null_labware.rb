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
end
