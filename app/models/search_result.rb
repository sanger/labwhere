# frozen_string_literal: true

##
# Used by Search
# An object which will be returned by the search or the api.
class SearchResult
  extend ActiveModel::Naming
  include Enumerable
  include ActiveModel::Serialization
  include ActionView::Helpers::TextHelper

  ##
  # An array of all of the objects that are returned by the search.
  attr_reader :results

  # enforces the limit. If the adjusted count is the same as limit no more results will be output.
  attr_reader :adjusted_count

  ##
  # The number of results returned by the search
  attr_accessor :count

  # The number of results the search is limited to
  attr_accessor :limit

  delegate :[], :empty?, to: :results

  ##
  # If the results are passed will add them to SearchResult otherwise create an empty result.
  # Reset the count.
  # Yields self with a block to allow stuff to be added in the initializer.
  def initialize(count: 0, limit: 0)
    @adjusted_count = 0
    @results = {}
    @count = count
    @limit = limit
    yield self if block_given?
  end

  ##
  #
  #  search_result = SearchResult.new(results)
  #  search_result.each do |search|
  #   ...
  #  end => each result
  def each(&block)
    results.each(&block)
  end

  ##
  # Add an object to the results hash with key k unless it is empty.
  # result with key will be replaced.
  # if adding result exceeds the limit then only spare capacity will be added.
  def add(k, v)
    return if adjusted_count >= limit

    unless v.empty?
      if adjusted_count + v.length > limit
        @results[k] = v.take(limit - adjusted_count)
        @adjusted_count = limit
      else
        @results[k] = v
        @adjusted_count += v.length
      end
    end
  end

  ##
  # If the number of results is under the limit then output the number of results.
  # If the number of results exceeds the limit state the limit and the actual number of results.
  def message
    return "Your search returned #{pluralize(count, "result")}." if count <= limit

    "Your search returned #{pluralize(count, "result")}. It has been limited to #{pluralize(limit, "result")}. Please refine your search."
  end
end
