class LabelSerializer < ActiveModel::Serializer

  self.root = false
  attributes :plate, :template

  def template
    "labwhere"
  end

  def plate
    {
      barcode: object.barcode,
      location: object.name,
      parent_location: object.parent.name
    }
  end
  
end