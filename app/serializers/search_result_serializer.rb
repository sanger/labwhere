# frozen_string_literal: true

# Serializer for Search Result
class SearchResultSerializer < ActiveModel::V08::Serializer
  attributes :count, :results
end
