class ScanSerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :message
end
