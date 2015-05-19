class LabelPrinter

  include ActiveModel::Serializers::JSON 

  self.include_root_in_json = true

  attr_reader :location
  
  def initialize(location)
    @location = location
  end

  def default_serializer_options
    {root: true}
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