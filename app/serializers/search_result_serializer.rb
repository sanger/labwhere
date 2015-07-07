# Serializer for Search Result
class SearchResultSerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :count, :results
end
