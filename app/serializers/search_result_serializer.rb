class SearchResultSerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :count, :results
end
