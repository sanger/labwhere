# frozen_string_literal: true

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
        barcode: location.barcode,
        parent_location: location.parent.name,
        location: location.name,
        label_name: "location"
      }
    end
  end
end
