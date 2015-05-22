##
# Take a location and turn it into some sensible JSON for the label printer.
# For example:
#  location = Location.create(name: "Location1")
#  label_printer = LabelPrinter.new(location)
#  label_printer.to_json =>
#  {\"label_printer\":
#    {\"labels\":[{\"template\":\"labwhere\",\"plate\":
#     {\"barcode\":\"location 1:1\",\"location\":\"location 1\",\"parent_location\":\"Empty\"}}],
#     \"header_text\":
#     {\"header_text1\":\"header by LabWhere\",\"header_text2\":\"header\"},
#     \"footer_text\":
#     {\"footer_text1\":\"footer by LabWhere\",\"footer_text2\":\"footer\"}
#    }
#  }" 
class LabelPrinter

  include ActiveModel::Serializers::JSON 

  self.include_root_in_json = true

  attr_reader :location
  
  def initialize(location)
    @location = location
  end

  def header_text
    { header_text1: "header by LabWhere", header_text2: "header"}
  end

  def footer_text
    { footer_text1: "footer by LabWhere", footer_text2: "footer"}
  end

  def labels
    [
      {
        template: "labwhere",
        plate: plate
      }
    ]
  end

  def plate
    {
      barcode: location.barcode,
      location: location.name,
      parent_location: location.parent.name
    }
  end

  def attributes
    {
      labels: labels,
      header_text: header_text,
      footer_text: footer_text
    }
  end

end