##
# Create a JSON request for label printing.
# Example:
#  {
#   "label_printer": {
#      { "header_text1": "header by LabWhere", "header_text2": "header" },
#      { "footer_text1": "footer by LabWhere", "footer_text2": "footer" },
#      labels:
#       [
#         {
#           "template": "labwhere",
#           "plate": {
#             "barcode": "location-2-1",
#             "location": "Location 2",
#             "parent_location": "Location 1"
#           }
#         }
#       ]
#   }
# }
class LabelPrinterSerializer < ActiveModel::Serializer

  # The printing service requires a root key
  self.root = true
  attributes :labels, :header_text, :footer_text

  # The printing service requires a header and a footer.
  # This is static.
  def header_text
    { header_text1: "header by LabWhere", header_text2: "header"}
  end

  def footer_text
    { footer_text1: "footer by LabWhere", footer_text2: "footer"}
  end

  #
  # Use the labwhere template.
  def labels
    [
      {
        template: "labwhere",
        plate: plate
      }
    ]
  end

  # location barcode as code 128
  # location name and location parent name will be printed as text.
  def plate
    {
      barcode: object.location.barcode,
      location: object.location.name,
      parent_location: object.location.parent.name
    }
  end

end
