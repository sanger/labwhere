class Label

  attr_accessor :locations

  def initialize(locations)
    @locations = Array(locations)
  end

  def to_h
    {
      body: body
    }
  end

  def body
    locations.map do |location|
      {
        location: {
          barcode: location.barcode,
          parent_location: location.parent.name,
          location: location.name
        }
      }
    end
  end

end