class Label

  attr_accessor :locations, :quantity

  def initialize(locations, quantity=1)
    @locations = Array(locations)
    @quantity = quantity
  end

  def to_h
    {
      body: body
    }
  end

  def body
    fill_locations
    locations * quantity
  end

  private

  def fill_locations 
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
