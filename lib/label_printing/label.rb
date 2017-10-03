class Label

  attr_accessor :locations, :copies

  def initialize(locations, copies=1)
    @locations = Array(locations)
    @copies = copies
  end

  def to_h
    {
      body: body
    }
  end

  def body
    filled_locations * copies
  end

  private

  def filled_locations 
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
