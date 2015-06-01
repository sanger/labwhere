class LabelPrinterSerializer < ActiveModel::Serializer

  self.root = true
  attributes :labels, :header_text, :footer_text

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
      barcode: object.location.barcode,
      location: object.location.name,
      parent_location: object.location.parent.name
    }
  end

end
