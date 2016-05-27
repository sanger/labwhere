class Label

  attr_accessor :locations

  def initialize(locations)
    @locations = Array(locations)
  end

  def to_h
    {
      header: header,
      body: body,
      footer: footer
    }
  end

  def header
    {
      'header_text_1' => 'header by LabWhere',
      'header_text_2' => 'header'
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

  def footer
    {
      'footer_text_1' => 'footer by LabWhere',
      'footer_text_2' => 'footer'
    }
  end

end